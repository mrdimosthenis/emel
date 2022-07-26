import emel/lazy/ml/decision_tree as lazy
import emel/ml/decision_tree as d3
import gleam/list
import gleam/map.{Map}
import gleam_zlists.{ZList} as zlist
import gleeunit/should

fn merge_attr(
  dataset: ZList(Map(String, String)),
  attr: String,
  attr_vals: ZList(String),
) -> ZList(Map(String, String)) {
  dataset
  |> zlist.zip(attr_vals)
  |> zlist.map(fn(t) {
    let #(m, s) = t
    map.insert(m, attr, s)
  })
}

fn risks() {
  [
    "high", "high", "moderate", "high", "low", "low", "high", "moderate", "low",
    "low", "high", "moderate", "low", "high",
  ]
  |> zlist.of_list
}

fn collaterals() {
  [
    "none", "none", "none", "none", "none", "adequate", "none", "adequate", "none",
    "adequate", "none", "none", "none", "none",
  ]
  |> zlist.of_list
}

fn incomes() {
  [
    "low", "moderate", "moderate", "low", "high", "high", "low", "high", "high",
    "high", "low", "moderate", "high", "moderate",
  ]
  |> zlist.of_list
}

fn depts() {
  [
    "high", "high", "low", "low", "low", "low", "low", "low", "low", "high", "high",
    "high", "high", "high",
  ]
  |> zlist.of_list
}

fn credit_histories() {
  [
    "bad", "unknown", "unknown", "unknown", "unknown", "unknown", "bad", "bad", "good",
    "good", "good", "good", "good", "bad",
  ]
  |> zlist.of_list
}

fn risk_dataset() -> ZList(Map(String, String)) {
  risks()
  |> zlist.map(fn(s) { [#("risk", s)] })
  |> zlist.map(map.from_list)
  |> merge_attr("collateral", collaterals())
  |> merge_attr("income", incomes())
  |> merge_attr("dept", depts())
  |> merge_attr("credit_history", credit_histories())
}

fn decisions() {
  [
    "No", "No", "Yes", "Yes", "Yes", "No", "Yes", "No", "Yes", "Yes", "Yes", "Yes",
    "Yes", "No",
  ]
  |> zlist.of_list
}

fn outlooks() {
  [
    "Sunny", "Sunny", "Overcast", "Rain", "Rain", "Rain", "Overcast", "Sunny", "Sunny",
    "Rain", "Sunny", "Overcast", "Overcast", "Rain",
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
    "High", "High", "High", "High", "Normal", "Normal", "Normal", "High", "Normal",
    "Normal", "Normal", "High", "Normal", "High",
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

fn decision_dataset() -> ZList(Map(String, String)) {
  decisions()
  |> zlist.map(fn(s) { [#("decision", s)] })
  |> zlist.map(map.from_list)
  |> merge_attr("outlook", outlooks())
  |> merge_attr("temperature", temperatures())
  |> merge_attr("humidity", humidities())
  |> merge_attr("wind", winds())
}

pub fn entropy_with_size_test() {
  risk_dataset()
  |> lazy.entropy_with_size("risk")
  |> should.equal(#(0.9657130652315666, 14))

  decision_dataset()
  |> lazy.entropy_with_size("decision")
  |> should.equal(#(0.9402859586706309, 14))
}

pub fn feature_entropy_test() {
  risk_dataset()
  |> lazy.feature_entropy("risk", "collateral", 14)
  |> should.equal(0.9083350856198091)

  risk_dataset()
  |> lazy.feature_entropy("risk", "income", 14)
  |> should.equal(0.5642953235635804)

  risk_dataset()
  |> lazy.feature_entropy("risk", "dept", 14)
  |> should.equal(0.9260282813042505)

  risk_dataset()
  |> lazy.feature_entropy("risk", "credit_history", 14)
  |> should.equal(0.8836520493378552)

  decision_dataset()
  |> lazy.feature_entropy("decision", "outlook", 14)
  |> should.equal(0.6935361388961918)

  decision_dataset()
  |> lazy.feature_entropy("decision", "temperature", 14)
  |> should.equal(0.9110633930116763)

  decision_dataset()
  |> lazy.feature_entropy("decision", "humidity", 14)
  |> should.equal(0.7884504573082896)

  decision_dataset()
  |> lazy.feature_entropy("decision", "wind", 14)
  |> should.equal(0.8921589282623617)
}

pub fn decision_tree_test() {
  decision_dataset()
  |> zlist.to_list
  |> d3.decision_tree(
    ["outlook", "temperature", "humidity", "wind"],
    "decision",
  )
  |> list.map(map.to_list)
  |> should.equal([
    [#("decision", "Yes"), #("outlook", "Overcast")],
    [#("decision", "No"), #("outlook", "Rain"), #("wind", "Strong")],
    [#("decision", "Yes"), #("outlook", "Rain"), #("wind", "Weak")],
    [#("decision", "No"), #("humidity", "High"), #("outlook", "Sunny")],
    [#("decision", "Yes"), #("humidity", "Normal"), #("outlook", "Sunny")],
  ])
}

pub fn classifier_test() {
  let f1 =
    risk_dataset()
    |> zlist.to_list
    |> d3.classifier(["collateral", "income", "dept", "credit_history"], "risk")
  let item1 =
    map.from_list([
      #("collateral", "none"),
      #("income", "high"),
      #("debt", "low"),
      #("credit_history", "good"),
    ])
  should.equal(f1(item1), "low")

  let f2 =
    decision_dataset()
    |> zlist.to_list
    |> d3.classifier(["outlook", "temperature", "humidity", "wind"], "decision")
  let item2 =
    map.from_list([
      #("outlook", "Rain"),
      #("temperature", "Hot"),
      #("humidity", "Normal"),
      #("wind", "Weak"),
    ])
  should.equal(f2(item2), "Yes")
}
