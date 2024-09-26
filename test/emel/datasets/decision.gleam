import emel/datasets/ut
import gleam/dict.{type Dict}
import gleam_zlists.{type ZList} as zlist

fn decisions() {
  [
    "No", "No", "Yes", "Yes", "Yes", "No", "Yes", "No", "Yes", "Yes", "Yes",
    "Yes", "Yes", "No",
  ]
  |> zlist.of_list
}

fn outlooks() {
  [
    "Sunny", "Sunny", "Overcast", "Rain", "Rain", "Rain", "Overcast", "Sunny",
    "Sunny", "Rain", "Sunny", "Overcast", "Overcast", "Rain",
  ]
  |> zlist.of_list
}

fn temperatures() {
  [
    "Hot", "Hot", "Hot", "Mild", "Cool", "Cool", "Cool", "Mild", "Cool", "Mild",
    "Mild", "Mild", "Hot", "Mild",
  ]
  |> zlist.of_list
}

fn humidities() {
  [
    "High", "High", "High", "High", "Normal", "Normal", "Normal", "High",
    "Normal", "Normal", "Normal", "High", "Normal", "High",
  ]
  |> zlist.of_list
}

fn winds() {
  [
    "Weak", "Strong", "Weak", "Weak", "Weak", "Strong", "Strong", "Weak", "Weak",
    "Weak", "Strong", "Strong", "Weak", "Strong",
  ]
  |> zlist.of_list
}

pub fn dataset() -> ZList(Dict(String, String)) {
  decisions()
  |> zlist.map(fn(s) { [#("decision", s)] })
  |> zlist.map(dict.from_list)
  |> ut.merge_attr("outlook", outlooks())
  |> ut.merge_attr("temperature", temperatures())
  |> ut.merge_attr("humidity", humidities())
  |> ut.merge_attr("wind", winds())
}
