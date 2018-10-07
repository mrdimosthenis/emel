defmodule Ml.KMeans do
  @moduledoc ~S"""
  Aims to partition n _observations_ into k _clusters_
  in which each _observation_ belongs to the _cluster_ with the nearest _mean_.

  """

  alias Help.Utils, as: Utils

  defmodule Cluster do
    @enforce_keys [:centroid, :points]
    defstruct [:centroid, :points]
  end

  defp mean([]), do: raise "No mean for empty group of points"
  defp mean([p | _] = points) do
    s = for i <- Utils.indices(p) do
      points
      |> Enum.map(fn v -> Enum.at(v, i) end)
      |> Enum.sum()
    end
    Enum.map(s, fn x -> x / length(points) end)
  end

  def initialize(_, k)when k <= 0, do: raise "K should be positive"
  def initialize(points, k) when k > length(points), do: raise "K should be less or equal to the number of points"
  def initialize(points, k) do
    shuffled = Enum.shuffle(points)
    selected = Enum.take(shuffled, k)
    rest = Enum.drop(shuffled, k)
    clusters = Enum.map(selected, fn p -> %Cluster{centroid: p, points: [p]} end)
    %{:clusters => clusters, :unassigned_points => rest}
  end

  def iterate(%{:clusters => clusters, :unassigned_points => unassigned_points}) do
    nil
  end

end
