import emel/lazy/ml/decision_tree as lazy
import gleam/map.{Map}
import gleam_zlists as zlist

pub fn decision_tree(
  dataset: List(Map(String, String)),
  attributes: List(String),
  class: String,
) -> List(Map(String, String)) {
  lazy.decision_tree(zlist.of_list(dataset), zlist.of_list(attributes), class)
  |> zlist.to_list
}

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
