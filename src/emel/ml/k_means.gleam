import emel/lazy/ml/k_means as lazy
import emel/utils/minigen as ut_gen
import emel/utils/zlist as ut_zlist
import gleam_zlists as zlist

pub fn clusters(points: List(List(Float)), k: Int) -> List(List(List(Float))) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.clusters(k, ut_gen.seed())
  |> zlist.map(ut_zlist.to_list_of_lists)
  |> zlist.to_list
}

pub fn classifier(dataset: List(List(Float)), k: Int) -> fn(List(Float)) -> Int {
  let f =
    dataset
    |> ut_zlist.to_zlist_of_zlists
    |> lazy.classifier(k, ut_gen.seed())
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
