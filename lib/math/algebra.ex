defmodule Math.Algebra do
  @moduledoc false

  @doc ~S"""
  The `first_minor` of a `matrix` obtained by removing just the `i`-row and the `j`-column from the `matrix`.
  It is required for calculating **cofactors**, which in turn are useful for computing both the **determinant**
  and **inverse** of square matrices.

  ## Examples

      iex> Math.Algebra.minor([[ 1.0, 4.0, 7.0],
      ...>                     [ 3.0, 0.0, 5.0],
      ...>                     [-1.0, 9.0,11.0]],
      ...>                     2,
      ...>                     3)
      13.0

      iex> Math.Algebra.minor([[6.0, 1.0, 1.0],
      ...>                     [4.0,-2.0, 5.0],
      ...>                     [2.0, 8.0, 7.0]],
      ...>                     1,
      ...>                     1)
      -54.0

      iex> Math.Algebra.determinant([[ 5.0,-7.0, 2.0, 2.0],
      ...>                           [ 0.0, 3.0, 0.0,-4.0],
      ...>                           [-5.0,-8.0, 0.0, 3.0],
      ...>                           [ 0.0, 5.0, 0.0,-6.0]],
      ...>                           1,
      ...>                           3)
      5.0

  """
  def first_minor(matrix, i, j), do: nil

  @doc ~S"""
  A value that can be computed from the elements of a square `matrix`.
  Geometrically, it can be viewed as the _scaling factor_ of the _linear transformation_ described by the `matrix`.

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
