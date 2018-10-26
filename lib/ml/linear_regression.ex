defmodule Ml.LinearRegression do
  @moduledoc ~S"""
  A linear approach to modelling the relationship between a _dependent variable_ and one or more _independent variables_.

  """

  alias Help.Utils
  alias Math.Algebra
  alias Math.Geometry

  @doc false
  defp c(points, i, j) do
    points
    |> Enum.map(
         fn p ->
           v = [1 | p]
           Enum.at(v, i) * Enum.at(v, j)
         end
       )
    |> Enum.sum()
  end

  @doc false
  defp cs([p | _] = points) do
    for i <- Utils.indices(p) do
      for j <- 0..length(p) do
        c(points, i, j)
      end
    end
  end

  @doc false
  defp coefficients(points) do
    points
    |> cs()
    |> Enum.map(fn vector -> Enum.drop(vector, -1) end)
  end

  @doc false
  defp constants(points) do
    points
    |> cs()
    |> Enum.map(fn vector -> Enum.at(vector, -1) end)
  end

  @doc ~S"""
  The set of _predictor function_'s _coefficients_ based on _observations_ (`points`).

    _observations_:
    ```
    f(1.794638, 15.15426     ) =   5.10998918E-1
    f(3.220726, 229.6516     ) = 105.6583692
    f(5.780040,   3.480201e+3) =   1.77699E3
    ```

    `points`:
    ```
    [[1.794638, 15.15426     ,   5.10998918E-1],
     [3.220726, 229.6516     , 105.6583692    ],
     [5.780040,   3.480201e+3,   1.77699E3    ]]
    ```

    ## Examples

      iex> Ml.LinearRegression.regression_coefficients([[1.794638, 15.15426     ,   5.10998918E-1],
      ...>                                              [3.220726, 229.6516     , 105.6583692    ],
      ...>                                              [5.780040,   3.480201e+3,   1.77699E3    ]])
      {:ok, [0.00834962613023635, -4.0888400103672184, 0.5173883086601628]}

      iex> Ml.LinearRegression.regression_coefficients([[1.0, 1.0 ],
      ...>                                              [2.0, 2.0 ],
      ...>                                              [3.0, 1.3 ],
      ...>                                              [4.0, 3.75],
      ...>                                              [5.0, 2.25]])
      {:ok, [0.785, 0.425]}


  """
  def regression_coefficients(points) do
    a = coefficients(points)
    b = constants(points)
    Algebra.cramer_solution(a, b)
  end

  @doc ~S"""
  The linear function of a set of _coefficients_ and _independent variables_,
  whose value is used to predict the outcome of a _dependent variable_.

        _observations_:
        ```
        f(1.794638, 15.15426     ) =   5.10998918E-1
        f(3.220726, 229.6516     ) = 105.6583692
        f(5.780040,   3.480201e+3) =   1.77699E3
        ```

        `points`:
        ```
        [[1.794638, 15.15426     ,   5.10998918E-1],
         [3.220726, 229.6516     , 105.6583692    ],
         [5.780040,   3.480201e+3,   1.77699E3    ]]
        ```

        ## Examples

          iex> {_, f} = Ml.LinearRegression.predictor_function([[1.794638, 15.15426     ,   5.10998918E-1],
          ...>                                                  [3.220726, 229.6516     , 105.6583692    ],
          ...>                                                  [5.780040,   3.480201e+3,   1.77699E3    ]])
          ...> f.([3, 230])
          106.74114058686602

  """
  def predictor_function(points) do
    {flag, result} = regression_coefficients(points)
    case flag do
      :ok ->
        {:ok, fn independent_variables -> Geometry.dot_product(result, [1 | independent_variables]) end}
      :error ->
        {:error, result}
    end
  end
end
