import emel/lazy/math/statistics as lazy
import gleam_zlists as zlist

/// A number that gives an idea of how random an outcome will be based on the `probability_values`
/// of each of the possible outcomes in a situation.
///
/// ```erlang
/// ProbabilityValues = [0.8, 0.05, 0.05, 0.1],
/// emel@math@statistics:entropy(ProbabilityValues).
/// % 0.5109640474436812
/// ```
pub fn entropy(probability_values: List(Float)) -> Float {
  probability_values
  |> zlist.of_list
  |> lazy.entropy
}

/// A measure of difference between two continuous variables.
///
/// ```erlang
/// Predictions = [5.0, 1.0, 0.0, 0.5],
/// Observations = [0.0, 1.0, -3.0, 0.5],
/// emel@math@statistics:mean_absolute_error(Predictions, Observations).
/// % 2.0
/// ```
pub fn mean_absolute_error(
  predictions: List(Float),
  observations: List(Float),
) -> Float {
  let lazy_predictions = zlist.of_list(predictions)
  let lazy_observations = zlist.of_list(observations)
  lazy.mean_absolute_error(lazy_predictions, lazy_observations)
}
