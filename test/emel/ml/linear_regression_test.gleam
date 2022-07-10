import emel/help/utils
import emel/lazy/ml/linear_regression as lazy
import emel/ml/linear_regression as lin_reg
import gleeunit/should

pub fn equation_terms_test() {
  [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
  |> utils.to_zlist_of_zlists
  |> lazy.equation_terms
  |> utils.to_list_of_lists
  |> should.equal([
    [2.0, 5.0, 7.0, 9.0],
    [5.0, 17.0, 22.0, 27.0],
    [7.0, 22.0, 29.0, 36.0],
  ])

  [[1.0, 1.0], [2.0, 2.0], [3.0, 1.3], [4.0, 3.75], [5.0, 2.25]]
  |> utils.to_zlist_of_zlists
  |> lazy.equation_terms
  |> utils.to_list_of_lists
  |> should.equal([[5.0, 15.0, 10.3], [15.0, 55.0, 35.15]])
}

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
