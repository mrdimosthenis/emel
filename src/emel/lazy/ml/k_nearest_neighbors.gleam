import emel/utils/min_sorted_zlist as mszl
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import emel/lazy/math/geometry
import gleam/int
import gleam/map
import gleam/pair
import gleam_zlists.{ZList} as zlist

pub fn k_nearest_neighbors(
  dataset: ZList(#(ZList(Float), a)),
  item: ZList(Float),
  k: Int,
) -> ZList(#(ZList(Float), a)) {
  dataset
  |> zlist.reduce(
    mszl.new(k),
    fn(el, acc) {
      let weight =
        el
        |> pair.first
        |> geometry.euclidean_distance(item)
      mszl.updated(acc, #(el, weight))
    },
  )
  |> mszl.extract
}

pub fn classifier(
  dataset: ZList(#(ZList(Float), String)),
  k: Int,
) -> fn(ZList(Float)) -> String {
  fn(xs) {
    dataset
    |> k_nearest_neighbors(xs, k)
    |> zlist.map(pair.second)
    |> ut_zlist.frequencies
    |> map.to_list
    |> zlist.of_list
    |> zlist.map(pair.map_second(_, int.to_float))
    |> ut_zlist.max_by(pair.second)
    |> ut_res.unsafe_res
    |> pair.first
  }
}

pub fn predictor(
  dataset: ZList(#(ZList(Float), Float)),
  k: Int,
) -> fn(ZList(Float)) -> Float {
  fn(xs) {
    dataset
    |> k_nearest_neighbors(xs, k)
    |> zlist.map(pair.second)
    |> ut_zlist.avg
    |> ut_res.unsafe_res
  }
}
