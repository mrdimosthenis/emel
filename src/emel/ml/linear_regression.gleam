import emel/help/utils
import emel/lazy/ml/linear_regression as lazy
import gleam/result
import gleam_zlists as zlist

pub fn regression_coefficients(
  points: List(List(Float)),
) -> Result(List(Float), String) {
  points
  |> utils.to_zlist_of_zlists
  |> lazy.regression_coefficients
  |> result.map(zlist.to_list)
}

pub fn predictor(
  dataset: List(#(List(Float), Float)),
) -> fn(List(Float)) -> Float {
  let f =
    dataset
    |> zlist.of_list
    |> zlist.map(fn(t) {
      let #(xs, y) = t
      #(zlist.of_list(xs), y)
    })
    |> lazy.predictor
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
