import emel/lazy/math/geometry as lazy
import emel/utils/zlist as ut_zlist
import gleam_zlists as zlist

/// The sum of the products of the corresponding entries of `x` and `y`.
///
/// ```erlang
/// X = [1.0, 2.0, 3.0],
/// Y = [4.0, -5.0, 6.0],
/// emel@math@geometry:dot_product(X, Y).
/// % 12.0
/// ```
pub fn dot_product(x: List(Float), y: List(Float)) -> Float {
  let lazy_x = zlist.of_list(x)
  let lazy_y = zlist.of_list(y)
  lazy.dot_product(lazy_x, lazy_y)
}

/// The ordinary straight-line distance between two points in _Euclidean space_.
///
/// ```erlang
/// X = [2.0, -1.0],
/// Y = [-2.0, 2.0],
/// emel@math@geometry:euclidean_distance(X, Y).
/// % 5.0
/// ```
pub fn euclidean_distance(x: List(Float), y: List(Float)) -> Float {
  let lazy_x = zlist.of_list(x)
  let lazy_y = zlist.of_list(y)
  lazy.euclidean_distance(lazy_x, lazy_y)
}

/// The _euclidean distance_ between the initial and the terminal point of the `vector`.
///
/// ```erlang
/// Vector = [6.0, 8.0],
/// emel@math@geometry:magnitude(Vector).
/// % 10.0
/// ```
pub fn magnitude(vector: List(Float)) -> Float {
  vector
  |> zlist.of_list
  |> lazy.magnitude
}

/// The neighbor that is closest to the given `point`.
///
/// ```erlang
/// Point = [0.9, 0.0],
/// Neighbors = [
///   [0.0, 0.0],
///   [0.0, 0.1],
///   [1.0, 0.0],
///   [1.0, 1.0]
/// ],
/// emel@math@geometry:nearest_neighbor(Point, Neighbors).
/// % [1.0, 0.0]
/// ```
pub fn nearest_neighbor(
  point: List(Float),
  neighbors: List(List(Float)),
) -> List(Float) {
  let lazy_point = zlist.of_list(point)
  neighbors
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.nearest_neighbor(lazy_point, _)
  |> zlist.to_list
}

/// The _arithmetic mean_ position of the `points`.
///
/// ```erlang
/// Points = [
///   [0.0, 0.0],
///   [0.0, 1.0],
///   [1.0, 0.0],
///   [1.0, 1.0]
/// ],
/// emel@math@geometry:centroid(Points).
/// % [0.5, 0.5]
/// ```
pub fn centroid(points: List(List(Float))) -> List(Float) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.centroid
  |> zlist.to_list
}
