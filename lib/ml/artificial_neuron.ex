defmodule Ml.ArtificialNeuron do
  @moduledoc """
  A mathematical function conceived as a model of biological neurons.
  Receives one or more separately weighted inputs, sums them and passes the sum through an _activation function_ to
  produce an output.

  """

  alias Math.Calculus
  alias Math.Geometry
  alias Help.Utils
  alias Math.Statistics

  defmodule Neuron do
    @moduledoc false
    @enforce_keys [:ws, :f, :der_f]
    defstruct [:ws, :f, :der_f]

    def new(ws, f \\ &Calculus.logistic_function/1, der_f \\ &Calculus.logistic_derivative/1) do
      weights = if is_number(ws) do
        Utils.rand_float(ws)
      else
        ws
      end
      %Neuron{ws: weights, f: f, der_f: der_f}
    end
  end

  defp neuron_output(%Neuron{ws: ws, f: f}, x) do
    x
    |> Geometry.dot_product(ws)
    |> f.()
  end

  defp update_neuron_weights(%Neuron{ws: ws, f: f, der_f: der_f}, x, y, a) do
    theta = Geometry.dot_product(x, ws)
    y_hat = f.(theta)
    deriv = der_f.(theta)
    common_factor = (-2) * (y - y_hat) * deriv
    weights = Enum.map(
      Enum.zip(ws, x),
      fn {w, xi} -> w - a * common_factor * xi end
    )
    %Neuron{ws: weights, f: f, der_f: der_f}
  end

  defp iterate(neuron, _, _, _, _, 0), do: neuron
  defp iterate(neuron, xs, ys, a, err_thres, max_iter) do
    new_neuron = Enum.reduce(
      Enum.zip(xs, ys),
      neuron,
      fn ({x, y}, acc) ->
        update_neuron_weights(acc, x, y, a)
      end
    )
    mean_abs_err = xs
                   |> Enum.map(fn x -> neuron_output(new_neuron, x) end)
                   |> Statistics.mean_absolute_error(ys)
    case mean_abs_err < err_thres do
      true -> new_neuron
      false -> iterate(new_neuron, xs, ys, a, err_thres, max_iter - 1)
    end
  end

  @doc """
  Returns the function that classifies an item by finding and using the _Artificial Neuron Function_.

  ## Examples

      iex> f = Ml.ArtificialNeuron.classifier([%{a: 0, b: 0, and: false},
      ...>                                     %{a: 0, b: 1, and: false},
      ...>                                     %{a: 1, b: 0, and: false},
      ...>                                     %{a: 1, b: 1, and: true},
      ...>                                    ], [:a, :b], :and)
      ...> f.(%{a: 1, b: 1})
      true

      iex> f = Ml.ArtificialNeuron.classifier([%{x: 0.0, y: 0.1, x_greater_than_y: false},
      ...>                                     %{x: 0.3, y: 0.2, x_greater_than_y: true},
      ...>                                     %{x: 0.2, y: 0.3, x_greater_than_y: false},
      ...>                                     %{x: 0.3, y: 0.4, x_greater_than_y: false},
      ...>                                     %{x: 0.4, y: 0.3, x_greater_than_y: true},
      ...>                                     %{x: 0.5, y: 0.5, x_greater_than_y: true},
      ...>                                     %{x: 0.5, y: 0.6, x_greater_than_y: false},
      ...>                                     %{x: 0.1, y: 0.2, x_greater_than_y: false},
      ...>                                     %{x: 0.0, y: 0.0, x_greater_than_y: true},
      ...>                                     %{x: 0.1, y: 0.0, x_greater_than_y: true},
      ...>                                     %{x: 0.2, y: 0.1, x_greater_than_y: true},
      ...>                                     %{x: 0.6, y: 0.7, x_greater_than_y: false},
      ...>                                    ], [:x, :y], :x_greater_than_y, 0.5, 0.001, 100)
      ...> f.(%{x: 0.45, y: 0.55})
      false

  """
  def classifier(
        dataset,
        continuous_attributes,
        boolean_class,
        learning_rate \\ 0.0001,
        err_thres \\ 0.1,
        max_iter \\ 10000,
        activation_function \\ &Calculus.logistic_function/1,
        activation_derivative \\ &Calculus.logistic_derivative/1
      ) do
    [x | _] = xs = Enum.map(dataset, fn row -> [1 | Utils.map_vals(row, continuous_attributes)] end)
    ys = Enum.map(
      dataset,
      fn row -> case row[boolean_class] do
                  true -> 1
                  false -> 0
                end
      end
    )
    init_neuron = Neuron.new(length(x) + 1, activation_function, activation_derivative)
    neuron = iterate(init_neuron, xs, ys, learning_rate, err_thres, max_iter)
    fn item ->
      item_vals = [1 | Utils.map_vals(item, continuous_attributes)]
      neuron_output(neuron, item_vals) >= 0.5
    end
  end

end
