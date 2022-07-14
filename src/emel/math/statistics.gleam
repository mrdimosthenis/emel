import emel/lazy/math/statistics as lazy
import gleam_zlists as zlist

pub fn entropy(probability_values: List(Float)) -> Float {
  probability_values
  |> zlist.of_list
  |> lazy.entropy
}
