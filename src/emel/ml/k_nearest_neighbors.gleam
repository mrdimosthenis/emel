//// A non-parametric method used for _classification_ and _regression_.
//// In both cases, the input consists of the k closest training examples in the feature space.

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

/// It searches through the `data` and returns the `k` most similar items to the `point`.
///
/// ```erlang
/// Data = [
///   {[7.0, 7.0], "bad"},
///   {[7.0, 4.0], "bad"},
///   {[3.0, 4.0], "good"},
///   {[1.0, 4.0], "good"}
/// ],
/// Point = [3.0, 7.0],
/// K = 3,
/// emel@ml@k_nearest_neighbors:k_nearest_neighbors(Data, Point, K).
/// % [
/// %   {[3.0, 4.0], "good"},
/// %   {[1.0, 4.0], "good"},
/// %   {[7.0, 7.0], "bad"}
/// % ]
/// ```
pub fn k_nearest_neighbors(
  data: List(#(List(Float), a)),
  point: List(Float),
  k: Int,
) -> List(#(List(Float), a)) {
  data
  |> to_lazy_dataset
  |> lazy.k_nearest_neighbors(zlist.of_list(point), k)
  |> zlist.map(pair.map_first(_, zlist.to_list))
  |> zlist.to_list
}

/// Returns the function that classifies a point by finding the `k` nearest neighbors.
///
/// ```erlang
/// Data = [
///   {[7.0, 7.0], "bad"},
///   {[7.0, 4.0], "bad"},
///   {[3.0, 4.0], "good"},
///   {[1.0, 4.0], "good"}
/// ],
/// K = 3,
/// F = emel@ml@k_nearest_neighbors:classifier(Data, K),
/// F([3.0, 7.0]).
/// % "good"
/// ```
pub fn classifier(
  data: List(#(List(Float), String)),
  k: Int,
) -> fn(List(Float)) -> String {
  let f =
    data
    |> to_lazy_dataset
    |> lazy.classifier(k)
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}

/// Returns the function that calculates the average value
/// of the `dependent variable` for the `k` nearest neighbors.
///
/// ```erlang
/// Data = [
///   {[0.0, 0.0, 0.0], 0.0},
///   {[0.5, 0.5, 0.5], 1.5},
///   {[1.0, 1.0, 1.0], 3.0},
///   {[1.5, 1.5, 1.5], 4.5},
///   {[2.0, 2.0, 2.0], 6.0},
///   {[2.5, 2.5, 2.5], 7.5},
///   {[3.0, 3.3, 3.0], 9.0}
/// ],
/// K = 2,
/// F = emel@ml@k_nearest_neighbors:predictor(Data, K),
/// F([1.725, 1.725, 1.725]).
/// % 5.25
/// ```
pub fn predictor(
  data: List(#(List(Float), Float)),
  k: Int,
) -> fn(List(Float)) -> Float {
  let f =
    data
    |> to_lazy_dataset
    |> lazy.predictor(k)
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
