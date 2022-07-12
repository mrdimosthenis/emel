import emel/lazy/math/geometry as lazy
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
