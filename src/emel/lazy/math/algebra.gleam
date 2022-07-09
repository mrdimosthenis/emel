import emel/help/utils
import gleam/int
import gleam_zlists.{ZList} as zlist

pub fn first_minor(
  matrix: ZList(ZList(Float)),
  i: Int,
  j: Int,
) -> ZList(ZList(Float)) {
  matrix
  |> utils.delete_at(i)
  |> zlist.map(fn(zl) { utils.delete_at(zl, j) })
}

pub fn determinant(matrix: ZList(ZList(Float))) -> Float {
  case zlist.count(matrix) {
    0 -> 1.0
    2 -> {
      let [[a, b], [c, d]] = utils.to_list_of_lists(matrix)
      a *. d -. c *. b
    }
    _ -> {
      assert Ok(hd) = zlist.head(matrix)
      hd
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
}

pub fn transpose(matrix: ZList(ZList(Float))) -> ZList(ZList(Float)) {
  case zlist.uncons(matrix) {
    Error(Nil) -> zlist.new()
    Ok(#(h, _)) ->
      case zlist.is_empty(h) {
        True -> zlist.new()
        False -> {
          let head =
            zlist.map(
              matrix,
              fn(x) {
                assert Ok(hd) = zlist.head(x)
                hd
              },
            )
          let tail =
            matrix
            |> zlist.map(fn(x) {
              assert Ok(tl) = zlist.tail(x)
              tl
            })
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
  case determinant(coefficients) {
    0.0 -> Error("No unique solution")
    determ -> {
      let transp = transpose(coefficients)
      constants
      |> zlist.with_index
      |> zlist.map(fn(t) {
        let #(_, i) = t
        let denominator =
          transp
          |> utils.replace_at(i, constants)
          |> transpose
          |> determinant
        denominator /. determ
      })
      |> Ok
    }
  }
}
