import emel/lazy/ml/k_nearest_neighbors as lazy
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
  let f =
    dataset
    |> to_lazy_dataset
    |> lazy.classifier(k)
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}

pub fn predictor(
  dataset: List(#(List(Float), Float)),
  k: Int,
) -> fn(List(Float)) -> Float {
  let f =
    dataset
    |> to_lazy_dataset
    |> lazy.predictor(k)
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
