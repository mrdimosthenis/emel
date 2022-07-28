import emel/lazy/ml/k_means as lazy
import emel/utils/zlist as ut_zlist
import gleam_zlists as zlist

pub fn clusters(points: List(List(Float)), k: Int) -> List(List(List(Float))) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.clusters(k)
  |> zlist.map(ut_zlist.to_list_of_lists)
  |> zlist.to_list
}
