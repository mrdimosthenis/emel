defmodule Ml.KMeans do
  @moduledoc ~S"""
  Aims to partition n _observations_ into k _clusters_
  in which each _observation_ belongs to the _cluster_ with the nearest _mean_.

  """
  alias Help.Utils, as: Utils
  alias Math.Geometry, as: Geometry

  defp point_groups(points, centroids) do
    points
    |> Enum.group_by(fn p -> Geometry.nearest_neighbor(p, centroids) end)
    |> Enum.map(fn {k, v} -> %Utils.Pair{first: k, second: v} end)
    |> Enum.sort_by(&(&1.first))
  end

  defp iterate(clusters) do
    groups = Enum.map(clusters, &(&1.second))
    points = Enum.concat(groups)
    old_centroids = Enum.map(clusters, &(&1.first))
    new_centroids = groups
                    |> Enum.map(&Geometry.centroid/1)
                    |> Enum.sort()
    case new_centroids do
      ^old_centroids ->
        clusters
      _ ->
        points
        |> point_groups(new_centroids)
        |> iterate()
    end
  end

  @doc ~S"""
  `Points` partitioned into `k` _clusters_ in which each _point_ belongs to the _cluster_ with the nearest _mean_.

  ## Examples

      iex> Ml.KMeans.clusters([[1.0, 1.0],
      ...>                     [2.0, 1.0],
      ...>                     [4.0, 3.0],
      ...>                     [5.0, 4.0]],
      ...>                     2)
      [[[1.0, 1.0], [2.0, 1.0]],
       [[4.0, 3.0], [5.0, 4.0]]]

      iex> Ml.KMeans.clusters([[0.0, 0.0],
      ...>                     [4.0, 4.0],
      ...>                     [9.0, 9.0],
      ...>                     [4.3, 4.3],
      ...>                     [9.9, 9.9],
      ...>                     [4.4, 4.4],
      ...>                     [0.1, 0.1]],
      ...>                     3)
      [[[0.0, 0.0], [0.1, 0.1]],
       [[4.0, 4.0], [4.3, 4.3], [4.4, 4.4]],
       [[9.0, 9.0], [9.9, 9.9]]]

  """
  def clusters(_, k) when k <= 0, do: raise "K should be positive"
  def clusters(points, k) when k > length(points), do: raise "K should be less or equal to the number of points"
  def clusters(points, k) do
    centroids = points
                |> Enum.shuffle()
                |> Enum.uniq()
                |> Enum.take(k)
    points
    |> point_groups(centroids)
    |> iterate()
    |> Enum.map(&(&1.second))
  end

end