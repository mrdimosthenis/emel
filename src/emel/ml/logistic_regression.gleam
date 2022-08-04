//// A classification algorithm used to assign observations to a set of two classes.
//// It transforms its output by using the _logistic sigmoid function_ to return a probability value
//// which can then be mapped to the classes.

import emel/lazy/ml/logistic_regression as lazy
import emel/utils/minigen as ut_gen
import gleam/pair
import gleam_zlists as zlist

/// Returns the function that classifies a poin by using the _Logistic Regression Algorithm_.
///
/// ```erlang
/// Data = [
///   {[0.0, 0.0], false},
///   {[0.0, 1.0], false},
///   {[1.0, 0.0], false},
///   {[1.0, 1.0], true}
/// ],
/// LearningRate = 0.01,
/// ErrorThreshold = 0.1,
/// MaxIterations = 1000,
/// F = emel@ml@logistic_regression:classifier(Data, LearningRate, ErrorThreshold, MaxIterations),
/// F([1.0, 1.0]).
/// % true
/// ```
pub fn classifier(
  data: List(#(List(Float), Bool)),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
) -> fn(List(Float)) -> Bool {
  let f =
  data
    |> zlist.of_list
    |> zlist.map(pair.map_first(_, zlist.of_list))
    |> lazy.classifier(
      learning_rate,
      error_threshold,
      max_iterations,
      ut_gen.seed(),
    )
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
