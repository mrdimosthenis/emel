defmodule Ml.Perceptron do
  @moduledoc false

  alias Math.Geometry
  alias Help.Utils

  def weights_updated(ws, x, y, a) when is_number(y) and (length(ws) == length(x)) do
    y_hat = Geometry.dot_product(ws, x)
    for i <- Utils.indices(ws) do
      Enum.at(ws, i) + a * (y - y_hat) * Enum.at(x, i)
    end
  end

  def weights_updated(ws, [x | _] = xs, ys, a) when (length(xs) == length(ys)) and (length(ws) == length(x)) do
    Enum.zip(xs, ys)
    |> Enum.reduce(ws, fn ({x, y}, acc) -> weights_updated(acc, x, y, a) end)
  end

end
