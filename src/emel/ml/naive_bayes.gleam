import emel/lazy/ml/naive_bayes as lazy
import gleam/map.{Map}
import gleam_zlists as zlist

pub fn classifier(
  dataset: List(Map(String, String)),
  discrete_attributes: List(String),
  class: String,
) -> fn(Map(String, String)) -> String {
  lazy.classifier(
    zlist.of_list(dataset),
    zlist.of_list(discrete_attributes),
    class,
  )
}
