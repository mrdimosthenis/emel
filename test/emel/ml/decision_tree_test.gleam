import emel/datasets/decision as decision
import emel/datasets/risk as risk
import emel/lazy/ml/decision_tree as lazy
import emel/ml/decision_tree as d3
import gleam/list
import gleam/map
import gleam_zlists as zlist
import gleeunit/should

pub fn entropy_with_size_test() {
  risk.dataset()
  |> lazy.entropy_with_size("risk")
  |> should.equal(#(0.9657130652315666, 14))

  decision.dataset()
  |> lazy.entropy_with_size("decision")
  |> should.equal(#(0.9402859586706309, 14))
}

pub fn feature_entropy_test() {
  risk.dataset()
  |> lazy.feature_entropy("risk", "collateral", 14)
  |> should.equal(0.9083350856198091)

  risk.dataset()
  |> lazy.feature_entropy("risk", "income", 14)
  |> should.equal(0.5642953235635804)

  risk.dataset()
  |> lazy.feature_entropy("risk", "dept", 14)
  |> should.equal(0.9260282813042505)

  risk.dataset()
  |> lazy.feature_entropy("risk", "credit_history", 14)
  |> should.equal(0.8836520493378552)

  decision.dataset()
  |> lazy.feature_entropy("decision", "outlook", 14)
  |> should.equal(0.6935361388961918)

  decision.dataset()
  |> lazy.feature_entropy("decision", "temperature", 14)
  |> should.equal(0.9110633930116763)

  decision.dataset()
  |> lazy.feature_entropy("decision", "humidity", 14)
  |> should.equal(0.7884504573082896)

  decision.dataset()
  |> lazy.feature_entropy("decision", "wind", 14)
  |> should.equal(0.8921589282623617)
}

pub fn decision_tree_test() {
  decision.dataset()
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
    risk.dataset()
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
    decision.dataset()
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
