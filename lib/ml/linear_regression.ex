defmodule Ml.LinearRegression do
  @moduledoc false

  alias Help.Utils, as: Utils

  @doc ~S"""
  Returns a new matrix whose rows are the columns of the original.

  ## Examples

      iex> Math.Algebra.transpose([[1.0, 4.0],
      ...>                         [3.0, 0.0]])
      [[1.0, 3.0],
       [4.0, 0.0]]

      iex> Math.Algebra.transpose([[6.0, 1.0, 1.0],
      ...>                        [4.0,-2.0, 5.0],
      ...>                        [2.0, 8.0, 7.0]])
      [[6.0, 4.0, 2.0],
       [1.0,-2.0, 8.0],
       [1.0, 5.0, 7.0]]

  """
  def constants(points) do
    xys = for n <- Utils.indices(
      points
      |> List.first()
      |> List.pop_at(-1)
      |> elem(1)
    ) do
      Enum.map(points, fn ls -> Enum.at([1 | ls], n) * List.last(ls) end)
    end
    Enum.map(xys, &Enum.sum/1)
  end
 #TODO a = [[1,9,3],[3,9,5],[4,6,6],[7,3,8],[9,1,7],[9,2,10]]
end
