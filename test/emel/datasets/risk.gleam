import emel/datasets/ut
import gleam/dict.{type Dict}
import gleam_zlists.{type ZList} as zlist

fn risks() {
  [
    "high", "high", "moderate", "high", "low", "low", "high", "moderate", "low",
    "low", "high", "moderate", "low", "high",
  ]
  |> zlist.of_list
}

fn collaterals() {
  [
    "none", "none", "none", "none", "none", "adequate", "none", "adequate",
    "none", "adequate", "none", "none", "none", "none",
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
    "high", "high", "low", "low", "low", "low", "low", "low", "low", "high",
    "high", "high", "high", "high",
  ]
  |> zlist.of_list
}

fn credit_histories() {
  [
    "bad", "unknown", "unknown", "unknown", "unknown", "unknown", "bad", "bad",
    "good", "good", "good", "good", "good", "bad",
  ]
  |> zlist.of_list
}

pub fn dataset() -> ZList(Dict(String, String)) {
  risks()
  |> zlist.map(fn(s) { [#("risk", s)] })
  |> zlist.map(dict.from_list)
  |> ut.merge_attr("collateral", collaterals())
  |> ut.merge_attr("income", incomes())
  |> ut.merge_attr("dept", depts())
  |> ut.merge_attr("credit_history", credit_histories())
}
