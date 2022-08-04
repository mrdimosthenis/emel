//// A _binary classification algorithm_ that makes its predictions based on a _linear predictor function_
//// combining a set of weights with the features.

import emel/lazy/ml/perceptron as lazy
import gleam/pair
import gleam_zlists as zlist

/// Returns the function that classifies a point by using the _Perceptron Algorithm_.
///
/// ```erlang
/// Data = [
///   {[0.0, 0.0], false},
///   {[0.0, 1.0], true},
///   {[1.0, 0.0], true},
///   {[1.0, 1.0], true}
/// ],
/// LearningRate = 0.01,
/// ErrorThreshold = 0.1,
/// MaxIterations = 1000,
/// F = emel@ml@perceptron:classifier(Data, LearningRate, ErrorThreshold, MaxIterations),
/// F([0.0, 0.0]).
/// % false
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
    |> lazy.classifier(learning_rate, error_threshold, max_iterations)
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
