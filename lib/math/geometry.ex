defmodule Math.Geometry do
  @moduledoc false

  @doc ~S"""
  The sum of the products of the corresponding entries of `x` and `y`.

  ## Examples

      iex> Math.Geometry.dot_product([-4, -9], [-1, 2])
      -14

      iex> Math.Geometry.dot_product([1, 2, 3], [4, -5, 6])
      12

  """
  def dot_product(x, y) do
    x
    |> Enum.zip(y)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

end
