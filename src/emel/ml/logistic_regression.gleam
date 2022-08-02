import emel/lazy/ml/logistic_regression as lazy
import emel/utils/minigen as ut_gen
import gleam/pair
import gleam_zlists as zlist

pub fn classifier(
  dataset: List(#(List(Float), Bool)),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
) -> fn(List(Float)) -> Bool {
  let f =
  dataset
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
