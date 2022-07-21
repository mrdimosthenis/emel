import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/float
import gleam/int
import gleam/order.{Eq}
import gleam_zlists.{ZList} as zlist

pub fn first_minor(
  matrix: ZList(ZList(Float)),
  i: Int,
  j: Int,
) -> ZList(ZList(Float)) {
  matrix
  |> ut_zlist.delete_at(i)
  |> zlist.map(fn(zl) { ut_zlist.delete_at(zl, j) })
}

pub fn determinant(matrix: ZList(ZList(Float))) -> Float {
  case zlist.count(matrix) {
    0 -> 1.0
    2 -> {
      let [[a, b], [c, d]] = ut_zlist.to_list_of_lists(matrix)
      a *. d -. c *. b
    }
    _ ->
      matrix
      |> zlist.head
      |> ut_res.unsafe_res
      |> zlist.with_index
      |> zlist.map(fn(t) {
        let #(elem, j) = t
        let delta =
          matrix
          |> first_minor(0, j)
          |> determinant
        let alpha = case int.is_even(j) {
          True -> elem
          False -> 0.0 -. elem
        }
        alpha *. delta
      })
      |> zlist.sum
  }
}

pub fn transpose(matrix: ZList(ZList(a))) -> ZList(ZList(a)) {
  case zlist.uncons(matrix) {
    Error(Nil) -> zlist.new()
    Ok(#(h, _)) ->
      case zlist.is_empty(h) {
        True -> zlist.new()
        False -> {
          let head = zlist.map(matrix, ut_res.unsafe_f(zlist.head))
          let tail =
            matrix
            |> zlist.map(ut_res.unsafe_f(zlist.tail))
            |> transpose
          zlist.cons(tail, head)
        }
      }
  }
}

pub fn cramer_solution(
  coefficients: ZList(ZList(Float)),
  constants: ZList(Float),
) -> Result(ZList(Float), String) {
  let determ = determinant(coefficients)
  case float.loosely_compare(determ, 0.0, 0.0001) {
    Eq -> Error("No unique solution")
    _ -> {
      let transp = transpose(coefficients)
      constants
      |> zlist.with_index
      |> zlist.map(fn(t) {
        let #(_, i) = t
        let denominator =
          transp
          |> ut_zlist.replace_at(i, constants)
          |> transpose
          |> determinant
        denominator /. determ
      })
      |> Ok
    }
  }
}
