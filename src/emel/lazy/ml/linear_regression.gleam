import emel/utils/result as ut_res
import emel/lazy/math/algebra
import emel/lazy/math/geometry
import gleam_zlists.{ZList} as zlist

pub fn equation_terms(points: ZList(ZList(Float))) -> ZList(ZList(Float)) {
  let m2 =
    points
    |> zlist.map(zlist.cons(_, 1.0))
    |> algebra.transpose
  let m1 =
    m2
    |> zlist.reverse
    |> zlist.drop(1)
    |> zlist.reverse
  zlist.map(
    m1,
    fn(v1) { zlist.map(m2, fn(v2) { geometry.dot_product(v1, v2) }) },
  )
}

pub fn regression_coefficients(
  points: ZList(ZList(Float)),
) -> Result(ZList(Float), String) {
  let #(constants, coefficients) =
    points
    |> equation_terms
    |> zlist.map(fn(v) {
      let #(h, t) =
        v
        |> zlist.reverse
        |> zlist.uncons
        |> ut_res.unsafe_res
      #(h, zlist.reverse(t))
    })
    |> zlist.unzip
  algebra.cramer_solution(coefficients, constants)
}

pub fn predictor(
  dataset: ZList(#(ZList(Float), Float)),
) -> fn(ZList(Float)) -> Float {
  let reg_coeff: ZList(Float) =
    dataset
    |> zlist.map(fn(t) {
      let #(xs, y) = t
      xs
      |> zlist.reverse
      |> zlist.cons(y)
      |> zlist.reverse
    })
    |> regression_coefficients
    |> ut_res.unsafe_res
  fn(xs) {
    xs
    |> zlist.cons(1.0)
    |> geometry.dot_product(reg_coeff)
  }
}
