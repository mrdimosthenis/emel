defmodule Ml.Perceptron do
  @moduledoc """
  A _binary classification algorithm_ that makes its predictions based on a _linear predictor function_
  combining a set of weights with the feature vector.

  """

  alias Math.Geometry
  alias Help.Utils
  alias Math.Statistics

  defp updated_weights(ws, x, y, a) when is_number(y) do
    y_hat = Geometry.dot_product(ws, x)
    for i <- Utils.indices(ws) do
      Enum.at(ws, i) + a * (y - y_hat) * Enum.at(x, i)
    end
  end

  defp updated_weights(ws, xs, ys, a) when length(ys) == length(xs) do
    Enum.zip(xs, ys)
    |> Enum.reduce(ws, fn ({x, y}, acc) -> updated_weights(acc, x, y, a) end)
  end

  defp iterate(ws, _, _, _, _, 0), do: ws
  defp iterate(ws, xs, ys, a, err_thres, max_iter) do
    new_ws = updated_weights(ws, xs, ys, a)
    mean_abs_err = xs
                   |> Enum.map(fn x -> Geometry.dot_product(new_ws, x) end)
                   |> Statistics.mean_absolute_error(ys)
    case mean_abs_err < err_thres do
      true -> new_ws
      false -> iterate(new_ws, xs, ys, a, err_thres, max_iter - 1)
    end
  end

  @doc """
  Returns the function that classifies an item by using the _Perceptron Algorithm_.

  ## Examples

      iex> f = Ml.Perceptron.classifier([%{a: 0, b: 0, or: false},
      ...>                               %{a: 0, b: 1, or: true},
      ...>                               %{a: 1, b: 0, or: true},
      ...>                               %{a: 1, b: 1, or: true},
      ...>                              ], [:a, :b], :or)
      ...> f.(%{a: 1, b: 0})
      true

      iex> f = Ml.Perceptron.classifier([%{x: 0.0, y: 0.1, x_less_than_y: true},
      ...>                               %{x: 0.3, y: 0.2, x_less_than_y: false},
      ...>                               %{x: 0.2, y: 0.3, x_less_than_y: true},
      ...>                               %{x: 0.3, y: 0.4, x_less_than_y: true},
      ...>                               %{x: 0.4, y: 0.3, x_less_than_y: false},
      ...>                               %{x: 0.5, y: 0.5, x_less_than_y: false},
      ...>                               %{x: 0.5, y: 0.6, x_less_than_y: true},
      ...>                               %{x: 0.1, y: 0.2, x_less_than_y: true},
      ...>                               %{x: 0.0, y: 0.0, x_less_than_y: false},
      ...>                               %{x: 0.1, y: 0.0, x_less_than_y: false},
      ...>                               %{x: 0.2, y: 0.1, x_less_than_y: false},
      ...>                               %{x: 0.6, y: 0.7, x_less_than_y: true},
      ...>                              ], [:x, :y], :x_less_than_y, 0.01, 0.001, 1000)
      ...> f.(%{x: 0.55, y: 0.35})
      false

  """
  def classifier(
        dataset,
        continuous_attributes,
        boolean_class,
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
    init_ws = Utils.duplicate(0, length(x))
    ws = iterate(init_ws, xs, ys, learning_rate, err_thres, max_iter)
    fn item ->
      item_vals = [1 | Utils.map_vals(item, continuous_attributes)]
      Geometry.dot_product(ws, item_vals) >= 0.5
    end
  end

end
