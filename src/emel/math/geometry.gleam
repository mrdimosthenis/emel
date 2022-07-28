import emel/lazy/math/geometry as lazy
import emel/utils/zlist as ut_zlist
import gleam_zlists as zlist

pub fn dot_product(x: List(Float), y: List(Float)) -> Float {
  let lazy_x = zlist.of_list(x)
  let lazy_y = zlist.of_list(y)
  lazy.dot_product(lazy_x, lazy_y)
}

pub fn euclidean_distance(x: List(Float), y: List(Float)) -> Float {
  let lazy_x = zlist.of_list(x)
  let lazy_y = zlist.of_list(y)
  lazy.euclidean_distance(lazy_x, lazy_y)
}

pub fn magnitude(vector: List(Float)) -> Float {
  vector
  |> zlist.of_list
  |> lazy.magnitude
}

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

pub fn centroid(points: List(List(Float))) -> List(Float) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.centroid
  |> zlist.to_list
}
