import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/float
import gleam_zlists.{type ZList} as zlist

pub fn dot_product(x: ZList(Float), y: ZList(Float)) -> Float {
  zlist.zip(x, y)
  |> zlist.map(fn(t) {
    let #(a, b) = t
    a *. b
  })
  |> zlist.sum
}

pub fn euclidean_distance(x: ZList(Float), y: ZList(Float)) -> Float {
  zlist.zip(x, y)
  |> zlist.map(fn(t) {
    let #(a, b) = t
    let d = b -. a
    d *. d
  })
  |> zlist.sum
  |> float.square_root
  |> ut_res.unsafe_res
}

pub fn magnitude(vector: ZList(Float)) -> Float {
  vector
  |> zlist.map(fn(_) { 0.0 })
  |> euclidean_distance(vector)
}

pub fn nearest_neighbor(
  point: ZList(Float),
  neighbors: ZList(ZList(Float)),
) -> ZList(Float) {
  neighbors
  |> ut_zlist.min_by(fn(p) { euclidean_distance(p, point) })
  |> ut_res.unsafe_res
}

pub fn centroid(points: ZList(ZList(Float))) -> ZList(Float) {
  let #(hd, tl) =
    points
    |> zlist.uncons
    |> ut_res.unsafe_res
  let #(s, n) =
    zlist.reduce(tl, #(hd, 1.0), fn(v, acc) {
      let #(acc_s, acc_n) = acc
      let next_acc_s =
        zlist.zip(acc_s, v)
        |> zlist.map(fn(t) {
          let #(si, vi) = t
          si +. vi
        })
      let next_acc_n = acc_n +. 1.0
      #(next_acc_s, next_acc_n)
    })
  zlist.map(s, fn(x) { x /. n })
}
