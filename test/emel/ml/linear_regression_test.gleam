import emel/ml/linear_regression as lin_reg
import gleeunit/should

pub fn regression_coefficients_test() {
  [
    [1.794638, 15.15426, 0.510998918],
    [3.220726, 229.6516, 105.6583692],
    [5.780040, 3480.201, 1776.99],
  ]
  |> lin_reg.regression_coefficients
  |> should.equal(Ok([
    0.00834962613023635, -4.0888400103672184, 0.5173883086601628,
  ]))

  [[1.0, 1.0], [2.0, 2.0], [3.0, 1.3], [4.0, 3.75], [5.0, 2.25]]
  |> lin_reg.regression_coefficients
  |> should.equal(Ok([0.785, 0.425]))
}
