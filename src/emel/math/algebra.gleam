import emel/lazy/math/algebra as lazy
import emel/utils/zlist as ut_zlist
import gleam/result
import gleam_zlists as zlist

pub fn first_minor(
  matrix: List(List(Float)),
  i: Int,
  j: Int,
) -> List(List(Float)) {
  matrix
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.first_minor(i, j)
  |> ut_zlist.to_list_of_lists
}

pub fn determinant(matrix: List(List(Float))) -> Float {
  matrix
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.determinant
}

pub fn transpose(matrix: List(List(a))) -> List(List(a)) {
  matrix
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.transpose
  |> ut_zlist.to_list_of_lists
}

pub fn cramer_solution(
  coefficients: List(List(Float)),
  constants: List(Float),
) -> Result(List(Float), String) {
  let lazy_coefficients = ut_zlist.to_zlist_of_zlists(coefficients)
  let lazy_constants = zlist.of_list(constants)
  lazy.cramer_solution(lazy_coefficients, lazy_constants)
  |> result.map(zlist.to_list)
}
