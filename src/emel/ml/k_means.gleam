//// Aims to partition n _observations_ into k _clusters_
//// in which each _observation_ belongs to the _cluster_ with the nearest _mean_.

import emel/lazy/ml/k_means as lazy
import emel/utils/minigen as ut_gen
import emel/utils/zlist as ut_zlist
import gleam_zlists as zlist

/// The `points` get partitioned into `k` _clusters_ in which each _point_ belongs to the _cluster_ with the nearest _mean_.
///
/// ```erlang
/// Points = [
///   [0.0, 0.0],
///   [4.0, 4.0],
///   [9.0, 9.0],
///   [4.3, 4.3],
///   [9.9, 9.9],
///   [4.4, 4.4],
///   [0.1, 0.1],
/// ],
/// K = 3,
/// emel@ml@k_means:clusters(Points, K).
/// % [
/// %   [[0.1, 0.1], [0.0, 0.0]],
/// %   [[4.0, 4.0], [4.3, 4.3], [4.4, 4.4]],
/// %   [[9.9, 9.9], [9.0, 9.0]],
/// % ]
/// ```
pub fn clusters(points: List(List(Float)), k: Int) -> List(List(List(Float))) {
  points
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.clusters(k, ut_gen.seed())
  |> zlist.map(ut_zlist.to_list_of_lists)
  |> zlist.to_list
}

/// Returns the function that classifies a point by identifying the index of the _cluster_ it belongs to.
///
/// ```erlang
/// Points = [
///   [0.0, 0.0],
///   [4.0, 4.0],
///   [9.0, 9.0],
///   [4.3, 4.3],
///   [9.9, 9.9],
///   [4.4, 4.4],
///   [0.1, 0.1],
/// ],
/// K = 3,
/// F = emel@ml@k_means:clusters(Points, K),
/// F([4.7, 4.7]).
/// % 1
/// ```
pub fn classifier(data: List(List(Float)), k: Int) -> fn(List(Float)) -> Int {
  let f =
    data
    |> ut_zlist.to_zlist_of_zlists
    |> lazy.classifier(k, ut_gen.seed())
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
