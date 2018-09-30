defmodule Math.Algebra do
  @moduledoc false

  @doc ~S"""
  A value that can be computed from the elements of a square matrix.
  Geometrically, it can be viewed as the scaling factor of the linear transformation described by the matrix.

  ## Examples

      iex> Math.Algebra.determinant([[3.0, 8.0],
      ...>                           [4.0, 6.0]])
      -14.0

      iex> Math.Algebra.determinant([[6.0, 1.0, 1.0],
      ...>                           [4.0,-2.0, 5.0],
      ...>                           [2.0, 8.0, 7.0]])
      -306.0

      iex> Math.Algebra.determinant([[4.0, 3.0, 2.0, 2.0],
      ...>                           [0.0, 1.0, 0.0,-2.0],
      ...>                           [1.0,-1.0, 3.0, 3.0],
      ...>                           [2.0, 3.0, 1.0, 1.0]])
      -240.0

  """
  def determinant(
        [
          [a, b | __],
          [c, d | _ ] | _
        ]
      ) when (__ === []), do: a * d - c * b

end
