import emel/lazy/math/statistics as lazy
import gleam_zlists as zlist

pub fn entropy(probability_values: List(Float)) -> Float {
  probability_values
  |> zlist.of_list
  |> lazy.entropy
}

pub fn mean_absolute_error(
  predictions: List(Float),
  observations: List(Float),
) -> Float {
  let lazy_predictions = zlist.of_list(predictions)
  let lazy_observations = zlist.of_list(observations)
  lazy.mean_absolute_error(lazy_predictions, lazy_observations)
}
