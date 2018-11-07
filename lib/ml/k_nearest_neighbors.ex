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
           |> Geometry.euclidean_distance(point) end
       )
    |> Enum.take(k)
  end

end
