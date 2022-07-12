import emel/lazy/ml/k_nearest_neighbors as lazy
import gleam/pair
import gleam_zlists as zlist

pub fn k_nearest_neighbors(
  item: List(Float),
  dataset: List(#(List(Float), String)),
  k: Int,
) -> List(#(List(Float), String)) {
  let lazy_item = zlist.of_list(item)
  let lazy_dataset =
    dataset
    |> zlist.of_list
    |> zlist.map(pair.map_first(_, zlist.of_list))
  lazy.k_nearest_neighbors(lazy_item, lazy_dataset, k)
  |> zlist.map(pair.map_first(_, zlist.to_list))
  |> zlist.to_list
}
