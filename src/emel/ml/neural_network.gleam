import emel/lazy/ml/neural_network as lazy
import emel/utils/minigen as ut_gen
import gleam/pair
import gleam_zlists as zlist

pub fn classifier(
  dataset: List(#(List(Float), String)),
  hidden_layers: List(Int),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
) -> fn(List(Float)) -> String {
  let lazy_dataset =
    dataset
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
