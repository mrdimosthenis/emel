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
