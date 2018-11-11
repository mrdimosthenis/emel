defmodule Math.Geometry do

  alias Help.Utils

  @doc ~S"""
  The sum of the products of the corresponding entries of `x` and `y`.

  ## Examples

      iex> Math.Geometry.dot_product([-4.0, -9.0], [-1.0, 2.0])
      -14.0

      iex> Math.Geometry.dot_product([1.0, 2.0, 3.0], [4.0, -5.0, 6.0])
      12.0

  """
  def dot_product(x, y) do
    x
    |> Enum.zip(y)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  @doc ~S"""
  The ordinary straight-line distance between two points in _Euclidean space_.

  ## Examples

      iex> Math.Geometry.euclidean_distance([2.0, -1.0], [-2.0, 2.0])
      5.0

      iex> Math.Geometry.euclidean_distance([0.0, 3.0, 4.0, 5.0], [7.0, 6.0, 3.0, -1.0])
      9.746794344808963

  """
  def euclidean_distance(x, y) when length(x) == length(y) do
    x
    |> Enum.zip(y)
    |> Enum.map(fn {a, b} -> (b - a) * (b - a) end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  @doc ~S"""
  The _euclidean distance_ between the initial and terminal point of the `vector`.

  ## Examples

      iex> Math.Geometry.magnitude([0.0, 2.0])
      2.0

      iex> Math.Geometry.magnitude([6.0, 8.0])
      10.0

      iex> Math.Geometry.magnitude([1.0, -2.0, 3.0])
      3.7416573867739413

  """
  def magnitude(vector) do
    zero = for _ <- vector, do: 0
    euclidean_distance(vector, zero)
  end


  @doc ~S"""
  The neighbor that is closest to the given `point`.

  ## Examples

      iex> Math.Geometry.nearest_neighbor([0.9, 0.0], [[0.0, 0.0], [0.0, 0.1], [1.0, 0.0], [1.0, 1.0]])
      [1.0, 0.0]

  """
  def nearest_neighbor(point, neighbors) do
    Enum.min_by(neighbors, fn n -> euclidean_distance(n, point) end)
  end

  @doc ~S"""
  The _arithmetic mean_ position of the `points`.

  ## Examples

      iex> Math.Geometry.centroid([[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]])
      [0.5, 0.5]

  """
  def centroid([]), do: raise "No centroid for empty group of points"
  def centroid([p | _] = points) do
    s = for i <- Utils.indices(p) do
      Enum.map(points, fn v -> Enum.at(v, i) end)
    end
    Enum.map(s, fn v -> Enum.sum(v) / length(points) end)
  end

end
