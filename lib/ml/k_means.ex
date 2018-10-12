defmodule Ml.KMeans do
  @moduledoc ~S"""
  Aims to partition n _observations_ into k _clusters_
  in which each _observation_ belongs to the _cluster_ with the nearest _mean_.

  """

  alias Help.Utils, as: Utils
  alias Math.Geometry, as: Geometry


  def iterate(points_of_cluster, centroids) do
    nil
  end

  def initialize(points, k) when k > length(points), do: raise "K should be less or equal to the number of points"
  def initialize(points, k) do
    centroids = points
                |> Enum.shuffle()
                |> Enum.uniq()
                |> Enum.take(k)
    groups = Enum.group_by(points, fn p -> Geometry.nearest_neighbor(p, centroids) end)
    iterate(groups)
  end

end
