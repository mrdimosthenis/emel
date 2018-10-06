defmodule Math.Algebra do
  @moduledoc false

  import Integer, only: [is_even: 1]
  alias Help.Utils, as: Utils

  @doc ~S"""
  The `first_minor` of a `matrix` obtained by removing just the `i`-row and the `j`-column from the `matrix`.
  It is required for calculating **cofactors**, which in turn are useful for computing both the **determinant**
  and **inverse** of square matrices. `i` and `j` are zero based.

  ## Examples

      iex> Math.Algebra.first_minor([[ 1.0, 4.0, 7.0],
      ...>                           [ 3.0, 0.0, 5.0],
      ...>                           [-1.0, 9.0,11.0]],
      ...>                           1,
      ...>                           2)
      [[ 1.0, 4.0],
       [-1.0, 9.0]]

      iex> Math.Algebra.first_minor([[6.0, 1.0, 1.0],
      ...>                           [4.0,-2.0, 5.0],
      ...>                           [2.0, 8.0, 7.0]],
      ...>                           0,
      ...>                           0)
      [[-2.0, 5.0],
       [ 8.0, 7.0]]

      iex> Math.Algebra.first_minor([[ 5.0,-7.0, 2.0, 2.0],
      ...>                           [ 0.0, 3.0, 0.0,-4.0],
      ...>                           [-5.0,-8.0, 0.0, 3.0],
      ...>                           [ 0.0, 5.0, 0.0,-6.0]],
      ...>                           0,
      ...>                           2)
      [[ 0.0, 3.0,-4.0],
       [-5.0,-8.0, 3.0],
       [ 0.0, 5.0,-6.0]]

  """
  def first_minor(matrix, i, j) do
    matrix
    |> List.delete_at(i)
    |> Enum.map(&(List.delete_at(&1, j)))
  end

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
      ...>                           [0.0, 1.0,-3.0, 3.0],
      ...>                           [0.0,-1.0, 3.0, 3.0],
      ...>                           [0.0, 3.0, 1.0, 1.0]])
      -240.0

  """
  def determinant([]), do: 1
  def determinant(
        [
          [a, b | rest],
          [c, d | _] | _
        ]
      ) when (rest === []), do: a * d - c * b
  def determinant(matrix) do
    matrix
    |> hd
    |> Enum.with_index()
    |> Enum.map(
         fn {elem, j} ->
           delta = matrix
                   |> first_minor(0, j)
                   |> determinant
           alpha = if is_even(j) do
             elem
           else
             -elem
           end
           alpha * delta
         end
       )
    |> Enum.sum()
  end

  @doc ~S"""
  A matrix whose rows are the columns of the original.

  ## Examples

      iex> Math.Algebra.transpose([[1.0, 4.0],
      ...>                         [3.0, 0.0]])
      [[1.0, 3.0],
       [4.0, 0.0]]

      iex> Math.Algebra.transpose([[6.0, 1.0, 1.0],
      ...>                         [4.0,-2.0, 5.0],
      ...>                         [2.0, 8.0, 7.0]])
      [[6.0, 4.0, 2.0],
       [1.0,-2.0, 8.0],
       [1.0, 5.0, 7.0]]

  """
  def transpose(matrix) do
    matrix
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc ~S"""
  The solution of a system of _linear equations_ by using Cramer's formula.

    system of linear equations with unknowns:
    ```
    2.0*x + 3.0*y = 6.0
    4.0*x + 9.0*y = 15.0
    ```

    `coefficients`:
    ```
    [[2.0, 3.0],
     [4.0, 9.0]]
    ```

    `constants`:
    ```
    [ 6.0,
     15.0]
    ```

  ## Examples

      iex> Math.Algebra.cramer_solution([[2.0, 3.0],
      ...>                               [4.0, 9.0]],
      ...>                              [6.0, 15.0])
      {:ok, [1.5, 1.0]}

      iex> Math.Algebra.cramer_solution([[1.0, 3.0,-2.0],
      ...>                               [3.0, 5.0, 6.0],
      ...>                               [2.0, 4.0, 3.0]],
      ...>                              [5.0, 7.0, 8.0])
      {:ok, [-15.0, 8.0, 2.0]}

      iex> Math.Algebra.cramer_solution([[0.0, 0.0],
      ...>                               [3.0, 5.0]],
      ...>                              [0.0, 12.0])
      {:error, "The system has not a unique solution"}

  """
  def cramer_solution(coefficients, constants) do
    determ = determinant(coefficients)
    if determ == 0 do
      {:error, "The system has not a unique solution"}
    else
      transposed = transpose(coefficients)
      solution = for n <- Utils.indices(constants) do
        denominator = transposed
                      |> List.replace_at(n, constants)
                      |> transpose
                      |> determinant
        denominator / determ
      end
      {:ok, solution}
    end
  end
end
