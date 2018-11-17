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
    @enforce_keys [:ws, :fun]
    defstruct [:ws, :fun]

    def new(
          ws,
          {f, der_f, inv_f} \\ {
            &Calculus.logistic_function/1,
            &Calculus.logistic_derivative/1,
            &Calculus.logistic_inverse/1
          }
        ) do
      weights = if is_number(ws) do
        for _ <- 1..ws do
          :rand.uniform()
        end
      else
        ws
      end

      %Neuron{ws: weights, fun: {f, der_f, inv_f}}
    end
  end

  def neuron_output(%Neuron{ws: ws, fun: {f, _, _}}, x) do
    x
    |> Geometry.dot_product(ws)
    |> f.()
  end

  def update_neuron_weights(%Neuron{ws: ws, fun: {f, der_f, inv_f}}, target_val, output_val, a) do
    error = target_val - output_val
    deriv = output_val
            |> inv_f.()
            |> der_f.()
    delta = deriv * error
    weights = Enum.map(ws, fn w -> (1 + a * delta) * w end)
    %Neuron{ws: weights, fun: {f, der_f, inv_f}}
  end

  defp iterate(neuron, _, _, _, _, 0), do: neuron
  defp iterate(%Neuron{ws: ws, fun: {f, der_f, inv_f}} = neuron, xs, ys, a, err_thres, max_iter) do
    IO.puts(inspect(ws))
    IO.puts("")
    new_neuron = Enum.reduce(
      Enum.zip(xs, ys),
      neuron,
      fn ({x, y}, acc) ->
        output = neuron_output(neuron, x)
        update_neuron_weights(acc, y, output, a)
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

  def classifier(
        dataset,
        continuous_attributes,
        boolean_class,
        {f, der_f, inv_f} \\ {
          &Calculus.logistic_function/1,
          &Calculus.logistic_derivative/1,
          &Calculus.logistic_inverse/1
        },
        learning_rate \\ 0.0001,
        err_thres \\ 0.1,
        max_iter \\ 10000
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
    init_neuron = Neuron.new(length(x) + 1)
    neuron = iterate(init_neuron, xs, ys, learning_rate, err_thres, max_iter)
    fn item ->
      item_vals = [1 | Utils.map_vals(item, continuous_attributes)]
      neuron_output(neuron, item_vals) >= 0.5
    end
  end

end
