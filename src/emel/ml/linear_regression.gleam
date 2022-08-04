//// A linear approach to modelling the relationship between
//// a list of _independent variables_ and a _dependent variable_.

import emel/lazy/ml/linear_regression as lazy
import emel/utils/zlist as ut_zlist
import gleam/pair
import gleam/result
import gleam_zlists as zlist

/// The list of the _predictor function_'s _coefficients_ based on _observations_ (`points`).
///
/// ```erlang
/// Points = [[1.0, 1.0, 1.0], [1.0, 2.0, 3.0], [2.0, 1.0, 0.0]],
/// emel@ml@linear_regression:regression_coefficients(Points).
/// % {ok, [0.0, -1.0, 2.0]}
/// ```
pub fn regression_coefficients(
  points: List(List(Float)),
) -> Result(List(Float), String) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.regression_coefficients
  |> result.map(zlist.to_list)
}

/// Returns the linear function that predicts the value of the _dependent variable_.
///
/// ```erlang
/// Data = [
///   {[1.794638, 15.15426], 0.510998918},
///   {[3.220726, 229.6516], 105.6583692},
///   {[5.780040, 3480.201], 1776.99}
/// ],
/// F = emel@ml@linear_regression:predictor(Data),
/// F([3.0, 230.0]).
/// % 106.74114058686602
/// ```
pub fn predictor(
  data: List(#(List(Float), Float)),
) -> fn(List(Float)) -> Float {
  let f =
    data
    |> zlist.of_list
    |> zlist.map(pair.map_first(_, zlist.of_list))
    |> lazy.predictor
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
