import emel/help/utils
import emel/lazy/math/algebra
import gleam_zlists.{ZList} as zlist

fn c(points: ZList(ZList(Float)), i: Int, j: Int) -> Float {
  points
  |> zlist.map(fn(p) {
    let v = zlist.cons(p, 1.0)
    let a = utils.unsafe2(zlist.fetch)(v, i)
    let b = utils.unsafe2(zlist.fetch)(v, j)
    a *. b
  })
  |> zlist.sum
}

fn cs(points: ZList(ZList(Float))) -> ZList(ZList(Float)) {
  let dim =
    points
    |> utils.unsafe(zlist.head)
    |> zlist.count
  let indices =
    zlist.indices()
    |> zlist.take(dim)
  let indices_plus =
    zlist.indices()
    |> zlist.take(dim + 1)
  zlist.map(
    indices,
    fn(i) { zlist.map(indices_plus, fn(j) { c(points, i, j) }) },
  )
}

fn coefficients(points: ZList(ZList(Float))) -> ZList(ZList(Float)) {
  points
  |> cs
  |> zlist.map(fn(vec) {
    vec
    |> zlist.reverse
    |> zlist.drop(1)
    |> zlist.reverse
  })
}

fn constants(points: ZList(ZList(Float))) -> ZList(Float) {
  points
  |> cs
  |> zlist.map(fn(vec) {
    vec
    |> zlist.reverse
    |> utils.unsafe(zlist.head)
  })
}

pub fn regression_coefficients(
  points: ZList(ZList(Float)),
) -> Result(ZList(Float), String) {
  let a = coefficients(points)
  let b = constants(points)
  algebra.cramer_solution(a, b)
}
