import gleam_zlists.{ZList} as zlist

pub type ZPath {
  ZDecision(attribute: String, condition: String, answer: String)
  ZBreakDown(attribute: String, condition: String, children: ZList(Path))
}

pub type ZDecisionTree =
  ZList(ZPath)

pub type Path {
  Decision(attribute: String, condition: String, answer: String)
  BreakDown(attribute: String, condition: String, children: List(Path))
}

pub type DecisionTree =
  List(Path)

fn to_path(zpath: ZPath) -> Path {
  case zpath {
    ZDecision(attribute, condition, answer) -> Decision(attribute, condition, answer)
    ZBreakDown(attribute, condition, children) ->
      children
      |> zlist.to_list
      |> BreakDown(attribute, condition, _)
  }
}

fn of_path(path: Path) -> ZPath {
  case path {
    Decision(attribute, condition, answer) -> ZDecision(attribute, condition, answer)
    BreakDown(attribute, condition, children) ->
      children
      |> zlist.of_list
      |> ZBreakDown(attribute, condition, _)
  }
}

pub fn to_decision_tree(zdtree: ZDecisionTree) -> DecisionTree {
  zdtree
  |> zlist.map(to_path)
  |> zlist.to_list
}

pub fn of_decision_tree(dtree: DecisionTree) -> ZDecisionTree {
  dtree
  |> zlist.of_list
  |> zlist.map(of_path)
}
