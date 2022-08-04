//// A collection of connected neurons, that looks like a biological brain.
//// Each connection, can transmit a signal from one neuron to another.

import emel/lazy/ml/neural_network as lazy
import emel/utils/minigen as ut_gen
import gleam/pair
import gleam_zlists as zlist

/// Returns the function that classifies a point by using the _Neural Network Framework_.
///
/// ```erlang
/// Data = [
///   {[0.8, 0.0, 0.0], "x"},
///   {[0.0, 0.9, 0.0], "y"},
///   {[0.0, 0.0, 0.8], "z"}
/// ],
/// HiddenLayers = [4],
/// LearningRate = 0.01,
/// ErrorThreshold = 0.1,
/// MaxIterations = 1000,
/// F = emel@ml@neural_network:classifier(Data, HiddenLayers, LearningRate, ErrorThreshold, MaxIterations),
/// F([0.0, 0.8, 0.0]).
/// % "y"
/// ```
pub fn classifier(
  data: List(#(List(Float), String)),
  hidden_layers: List(Int),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
) -> fn(List(Float)) -> String {
  let lazy_dataset =
    data
    |> zlist.of_list
    |> zlist.map(pair.map_first(_, zlist.of_list))
  let lazy_hidden_layers = zlist.of_list(hidden_layers)
  let seed = ut_gen.seed()
  let f =
    lazy.classifier(
      lazy_dataset,
      lazy_hidden_layers,
      learning_rate,
      error_threshold,
      max_iterations,
      seed,
    )
  fn(xs) {
    xs
    |> zlist.of_list
    |> f
  }
}
