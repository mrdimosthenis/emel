defmodule Ml.Perceptron do
  @moduledoc false

  alias Math.Geometry
  alias Help.Utils

  def weights_for_example(ws, x, y, a) when (length(ws) == length(x)) do
    y_hat = Geometry.dot_product(ws, x)
    for i <- Utils.indices(ws) do
      Enum.at(ws, i) + a * (y - y_hat) * Enum.at(x, i)
    end
  end

  def weights_for_group(ws, xs, ys, a) do
    Enum.zip(xs, ys)
    |> Enum.reduce(ws, fn ({x, y}, acc) -> weights_for_example(acc, x, y, a) end)
  end

end
