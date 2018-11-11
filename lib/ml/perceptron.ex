defmodule Ml.Perceptron do
  @moduledoc false

  alias Math.Geometry
  alias Help.Utils
  alias Math.Statistics

  def updated_weights(ws, x, y, a) when is_number(y) do
    y_hat = Geometry.dot_product(ws, x)
    for i <- Utils.indices(ws) do
      Enum.at(ws, i) + a * (y - y_hat) * Enum.at(x, i)
    end
  end

  def updated_weights(ws, xs, ys, a) when length(ys) == length(xs) do
    Enum.zip(xs, ys)
    |> Enum.reduce(ws, fn ({x, y}, acc) -> updated_weights(acc, x, y, a) end)
  end

  def iterate(ws, _, _, _, _, 0), do: ws
  def iterate(ws, xs, ys, a, err_thres, max_iter) do
    new_ws = updated_weights(ws, xs, ys, a)
    mean_abs_err = xs
                   |> Enum.map(fn x -> Geometry.dot_product(new_ws, x) end)
                   |> Statistics.mean_absolute_error(ys)
    case mean_abs_err < err_thres do
      true -> new_ws
      false -> iterate(new_ws, xs, ys, a, err_thres, max_iter - 1)
    end
  end

  def classifier(
        dataset,
        continuous_attributes,
        boolean_class,
        learning_rate \\ 0.0001,
        err_thres \\ 0.21,
        max_iter \\ 1000
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
    ws = iterate(init_ws, xs, ys, learning_rate, err_thres, max_iter - 1)
    fn item ->
      item_vals = [1 | Utils.map_vals(item, continuous_attributes)]
      Geometry.dot_product(ws, item_vals) >= 0.5
    end
  end

end
