defmodule Ml.KNearestNeighbors do
  @moduledoc ~S"""
    A non-parametric method used for _classification_ and _regression_.
    In both cases, the input consists of the k closest training examples in the feature space.

  """
  alias Help.Utils
  alias Math.Geometry

  @doc ~S"""
  It searches through the entire `dataset` and returns the `k` most similar items to the `item`.

  ## Examples

      iex> Ml.KNearestNeighbors.k_nearest_neighbors(%{x1: 3.0, x2: 7.0},
      ...>                                          [%{x1: 7.0, x2: 7.0, y: "bad"},
      ...>                                           %{x1: 7.0, x2: 4.0, y: "bad"},
      ...>                                           %{x1: 3.0, x2: 4.0, y: "good"},
      ...>                                           %{x1: 1.0, x2: 4.0, y: "good"}],
      ...>                                          [:x1, :x2],
      ...>                                          3)
      [%{x1: 3.0, x2: 4.0, y: "good"},
       %{x1: 1.0, x2: 4.0, y: "good"},
       %{x1: 7.0, x2: 7.0, y: "bad"}]

  """
  def k_nearest_neighbors(item, dataset, continuous_attributes, k) do
    point = Utils.map_vals(item, continuous_attributes)
    dataset
    |> Enum.sort_by(
         fn row ->
           row
           |> Utils.map_vals(continuous_attributes)
           |> Geometry.euclidean_distance(point)
         end
       )
    |> Enum.take(k)
  end

  @doc ~S"""
  Returns the function that classifies an item by finding the `k` nearest neighbors.

  ## Examples

      iex> f = Ml.KNearestNeighbors.classifier([%{x1: 7.0, x2: 7.0, y: "bad"},
      ...>                                      %{x1: 7.0, x2: 4.0, y: "bad"},
      ...>                                      %{x1: 3.0, x2: 4.0, y: "good"},
      ...>                                      %{x1: 1.0, x2: 4.0, y: "good"}],
      ...>                                     [:x1, :x2], :y, 3)
      ...> f.(%{x1: 3.0, x2: 7.0})
      "good"

  """
  def classifier(dataset, continuous_attributes, class, k) do
    fn item ->
      class_values = item
                     |> k_nearest_neighbors(dataset, continuous_attributes, k)
                     |> Enum.map(fn row -> row[class] end)
      class_values
      |> Enum.uniq()
      |> Enum.max_by(
           fn v ->
             Enum.count(class_values, fn x -> x == v end)
           end
         )
    end
  end

  @doc ~S"""
  Returns the function that calculates the average value of the `dependent_variable` of the `k` nearest neighbors.

        ## Examples

          iex> f = Ml.KNearestNeighbors.predictor([%{x1: 0.0, x2: 0.0, x3: 0.0, y: 0.0},
          ...>                                     %{x1: 0.5, x2: 0.5, x3: 0.5, y: 1.5},
          ...>                                     %{x1: 1.0, x2: 1.0, x3: 1.0, y: 3.0},
          ...>                                     %{x1: 1.5, x2: 1.5, x3: 1.5, y: 4.5},
          ...>                                     %{x1: 2.0, x2: 2.0, x3: 2.0, y: 6.0},
          ...>                                     %{x1: 2.5, x2: 2.5, x3: 2.5, y: 7.5},
          ...>                                     %{x1: 3.0, x2: 3.3, x3: 3.0, y: 9.0}],
          ...>                                    [:x1, :x2, :x3], :y, 2)
          ...> f.(%{x1: 1.725, x2: 1.725, x3: 1.725})
          5.25

  """
  def predictor(dataset, independent_variables, dependent_variable, k) do
    fn item ->
      sum = item
            |> k_nearest_neighbors(dataset, independent_variables, k)
            |> Enum.map(fn row -> row[dependent_variable] end)
            |> Enum.sum()
      sum / k
    end
  end

end
