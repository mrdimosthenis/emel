import emel/lazy/ml/k_nearest_neighbors as lazy
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/int
import gleam/map
import gleam/pair
import gleam_zlists.{ZList} as zlist

fn to_lazy_dataset(
  dataset: List(#(List(Float), a)),
) -> ZList(#(ZList(Float), a)) {
  dataset
  |> zlist.of_list
  |> zlist.map(pair.map_first(_, zlist.of_list))
}

pub fn k_nearest_neighbors(
  dataset: List(#(List(Float), a)),
  item: List(Float),
  k: Int,
) -> List(#(List(Float), a)) {
  dataset
  |> to_lazy_dataset
  |> lazy.k_nearest_neighbors(zlist.of_list(item), k)
  |> zlist.map(pair.map_first(_, zlist.to_list))
  |> zlist.to_list
}

pub fn classifier(
  dataset: List(#(List(Float), String)),
  k: Int,
) -> fn(List(Float)) -> String {
  fn(xs) {
    dataset
    |> to_lazy_dataset
    |> lazy.k_nearest_neighbors(zlist.of_list(xs), k)
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
  dataset: List(#(List(Float), Float)),
  k: Int,
) -> fn(List(Float)) -> Float {
  fn(xs) {
    dataset
    |> to_lazy_dataset
    |> lazy.k_nearest_neighbors(zlist.of_list(xs), k)
    |> zlist.map(pair.second)
    |> ut_zlist.avg
    |> ut_res.unsafe_res
  }
}
