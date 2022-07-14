import emel/lazy/ml/linear_regression as lazy
import emel/utils/zlist as ut_zlist
import emel/math/geometry
import gleam/list
import gleam/result
import gleam_zlists as zlist

pub fn regression_coefficients(
  points: List(List(Float)),
) -> Result(List(Float), String) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.regression_coefficients
  |> result.map(zlist.to_list)
}

pub fn predictor(
  dataset: List(#(List(Float), Float)),
) -> fn(List(Float)) -> Float {
  assert Ok(reg_coeff) =
    dataset
    |> zlist.of_list
    |> zlist.map(fn(t) {
      let #(xs, y) = t
      xs
      |> zlist.of_list
      |> zlist.reverse
      |> zlist.cons(y)
      |> zlist.reverse
    })
    |> lazy.regression_coefficients
    |> result.map(zlist.to_list)
  fn(xs) {
    xs
    |> list.prepend(1.0)
    |> geometry.dot_product(reg_coeff)
  }
}
