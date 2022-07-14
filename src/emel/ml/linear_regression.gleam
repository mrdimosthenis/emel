import emel/lazy/ml/linear_regression as lazy
import emel/utils/zlist as ut_zlist
import gleam/pair
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
  let f =
    dataset
    |> zlist.of_list
    |> zlist.map(pair.map_first(_, zlist.of_list))
    |> lazy.predictor
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
