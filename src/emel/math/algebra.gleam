import emel/help/utils
import emel/lazy/math/algebra as lazy
import gleam/result
import gleam_zlists as zlist

pub fn first_minor(
  matrix: List(List(Float)),
  i: Int,
  j: Int,
) -> List(List(Float)) {
  matrix
  |> utils.to_zlist_of_zlists
  |> lazy.first_minor(i, j)
  |> utils.to_list_of_lists
}

pub fn determinant(matrix: List(List(Float))) -> Float {
  matrix
  |> utils.to_zlist_of_zlists
  |> lazy.determinant
}

pub fn transpose(matrix: List(List(Float))) -> List(List(Float)) {
  matrix
  |> utils.to_zlist_of_zlists
  |> lazy.transpose
  |> utils.to_list_of_lists
}

pub fn cramer_solution(
  coefficients: List(List(Float)),
  constants: List(Float),
) -> Result(List(Float), String) {
  let lazy_coefficients = utils.to_zlist_of_zlists(coefficients)
  let lazy_constants = zlist.of_list(constants)
  lazy.cramer_solution(lazy_coefficients, lazy_constants)
  |> result.map(zlist.to_list)
}
