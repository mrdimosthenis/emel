import gleam_zlists.{ZList} as zlist

pub type ZPath {
  ZDecision(index: Int, condition: String, answer: String)
  ZBreakDown(index: Int, condition: String, children: ZList(Path))
}

pub type ZDecisionTree =
  ZList(ZPath)

pub type Path {
  Decision(index: Int, condition: String, answer: String)
  BreakDown(index: Int, condition: String, children: List(Path))
}

pub type DecisionTree =
  List(Path)

pub fn to_path(zpath: ZPath) -> Path {
  case zpath {
    ZDecision(index, condition, answer) -> Decision(index, condition, answer)
    ZBreakDown(index, condition, children) ->
      children
      |> zlist.to_list
      |> BreakDown(index, condition, _)
  }
}

pub fn of_path(path: Path) -> ZPath {
  case path {
    Decision(index, condition, answer) -> ZDecision(index, condition, answer)
    BreakDown(index, condition, children) ->
      children
      |> zlist.of_list
      |> ZBreakDown(index, condition, _)
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
