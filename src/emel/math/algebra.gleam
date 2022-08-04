import emel/lazy/math/algebra as lazy
import emel/utils/zlist as ut_zlist
import gleam/result
import gleam_zlists as zlist

/// The `first_minor` of a `matrix` obtained by removing just the `i`-row and the `j`-column from the `matrix`.
/// It is required for calculating _cofactors_, which in turn are useful for computing both the _determinant_
/// and the _inverse_ of square matrices. `i` and `j` are zero based.
///
/// ```erlang
/// Matrix = [
///   [5.0, -7.0, 2.0, 2.0],
///   [0.0, 3.0, 0.0, -4.0],
///   [-5.0, -8.0, 0.0, 3.0],
///   [0.0, 5.0, 0.0, -6.0],
/// ],
/// I = 0,
/// J = 2,
/// emel@math@algebra:first_minor(Matrix, I, J).
/// % [
/// %   [0.0, 3.0, -4.0],
/// %   [-5.0, -8.0, 3.0],
/// %   [0.0, 5.0, -6.0]
/// % ]
/// ```
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

/// A value that can be computed from the elements of a square `matrix`.
/// Geometrically, it can be viewed as the _scaling factor_ of the _linear transformation_ described by the `matrix`.
///
/// ```erlang
/// Matrix = [
///   [3.0, 8.0],
///   [4.0, 6.0]
/// ],
/// emel@math@algebra:determinant(Matrix).
/// % -14.0
/// ```
pub fn determinant(matrix: List(List(Float))) -> Float {
  matrix
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.determinant
}

/// A matrix whose rows are the columns of the original.
///
/// ```erlang
/// Matrix = [
///   [6.0, 1.0, 1.0],
///   [4.0, -2.0, 5.0],
///   [2.0, 8.0, 7.0]
/// ],
/// emel@math@algebra:transpose(Matrix).
/// % [
/// %   [6.0, 4.0, 2.0],
/// %   [1.0, -2.0, 8.0],
/// %   [1.0, 5.0, 7.0]
/// % ]
/// ```
pub fn transpose(matrix: List(List(a))) -> List(List(a)) {
  matrix
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.transpose
  |> ut_zlist.to_list_of_lists
}

/// The solution of a system of _linear equations_ by using Cramer's formula.
///
/// ```erlang
/// Coefficients = [
///   [1.0, 3.0, -2.0],
///   [3.0, 5.0, 6.0],
///   [2.0, 4.0, 3.0]
/// ],
/// Constants = [5.0, 7.0, 8.0],
/// emel@math@algebra:cramer_solution(Coefficients, Constants).
/// % {ok, [-15.0, 8.0, 2.0]}
/// ```
pub fn cramer_solution(
  coefficients: List(List(Float)),
  constants: List(Float),
) -> Result(List(Float), String) {
  let lazy_coefficients = ut_zlist.to_zlist_of_zlists(coefficients)
  let lazy_constants = zlist.of_list(constants)
  lazy.cramer_solution(lazy_coefficients, lazy_constants)
  |> result.map(zlist.to_list)
}
