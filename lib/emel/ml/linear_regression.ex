defmodule Emel.Ml.LinearRegression do
  @moduledoc """
  A linear approach to modelling the relationship between a _dependent variable_ and one or more _independent variables_.

  """

  alias Emel.Help.Utils
  alias Emel.Math.Algebra
  alias Emel.Math.Geometry

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

  @doc """
  The set of _predictor function_'s _coefficients_ based on _observations_ (`points`).

  ## Examples

      iex> Emel.Ml.LinearRegression.regression_coefficients([[1.794638, 15.15426     ,   5.10998918E-1],
      ...>                                                   [3.220726, 229.6516     , 105.6583692    ],
      ...>                                                   [5.780040,   3.480201e+3,   1.77699E3    ]])
      {:ok, [0.00834962613023635, -4.0888400103672184, 0.5173883086601628]}

      iex> Emel.Ml.LinearRegression.regression_coefficients([[1.0, 1.0 ],
      ...>                                                   [2.0, 2.0 ],
      ...>                                                   [3.0, 1.3 ],
      ...>                                                   [4.0, 3.75],
      ...>                                                   [5.0, 2.25]])
      {:ok, [0.785, 0.425]}


  """
  def regression_coefficients(points) do
    a = coefficients(points)
    b = constants(points)
    Algebra.cramer_solution(a, b)
  end

  @doc """
  Returns the linear function that predicts the value of the _dependent variable_.

  ## Examples

      iex> f = Emel.Ml.LinearRegression.predictor([%{x1: 1.794638, x2: 15.15426     , y:   5.10998918E-1},
      ...>                                         %{x1: 3.220726, x2: 229.6516     , y: 105.6583692    },
      ...>                                         %{x1: 5.780040, x2:   3.480201e+3, y:   1.77699E3    }],
      ...>                                        [:x1, :x2], :y)
      ...> f.(%{x1: 3.0, x2: 230.0})
      106.74114058686602

  """
  def predictor(dataset, independent_variables, dependent_variable) do
    vars = independent_variables ++ [dependent_variable]
    {flag, result} = dataset
                     |> Enum.map(fn row -> Utils.map_vals(row, vars) end)
                     |> regression_coefficients()
    case flag do
      :ok -> fn item -> Geometry.dot_product(result, [1 | Utils.map_vals(item, independent_variables)]) end
      :error -> raise "The system of linear equations does not have a solution"
    end
  end

end
