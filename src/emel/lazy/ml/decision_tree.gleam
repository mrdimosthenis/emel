import emel/lazy/math/statistics as stats
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/dict.{type Dict}
import gleam/int
import gleam/pair
import gleam_zlists.{type ZList} as zlist

pub fn entropy_with_size(
  dataset: ZList(Dict(String, String)),
  class_attr: String,
) -> #(Float, Int) {
  let #(freqs, size) =
    dataset
    |> zlist.map(ut_res.unsafe_get(_, class_attr))
    |> ut_zlist.freqs_with_size
  let entropy =
    freqs
    |> zlist.map(pair.second)
    |> zlist.map(fn(x) { int.to_float(x) /. int.to_float(size) })
    |> stats.entropy
  #(entropy, size)
}

pub fn feature_entropy(
  dataset: ZList(Dict(String, String)),
  class_attr: String,
  feature: String,
  dataset_size: Int,
) -> Float {
  dataset
  |> ut_zlist.group_by(ut_res.unsafe_get(_, feature))
  |> zlist.map(pair.second)
  |> zlist.map(fn(sub_dataset) {
    let #(e, len) = entropy_with_size(sub_dataset, class_attr)
    let p = int.to_float(len) /. int.to_float(dataset_size)
    p *. e
  })
  |> zlist.sum
}

fn same_class(
  rule: Dict(String, String),
  class_attr: String,
  sub_dataset: ZList(Dict(String, String)),
) -> ZList(Dict(String, String)) {
  sub_dataset
  |> zlist.head
  |> ut_res.unsafe_res
  |> ut_res.unsafe_get(class_attr)
  |> dict.insert(rule, class_attr, _)
  |> zlist.singleton
}

fn exhausted_attributes(
  rule: Dict(String, String),
  class_attr: String,
  grouped_by_class: ZList(#(String, ZList(Dict(String, String)))),
) -> ZList(Dict(String, String)) {
  grouped_by_class
  |> ut_zlist.max_by(fn(t) {
    t
    |> pair.second
    |> zlist.count
    |> int.to_float
  })
  |> ut_res.unsafe_res
  |> pair.first
  |> dict.insert(rule, class_attr, _)
  |> zlist.singleton
}

fn unfold_rule(
  rule: Dict(String, String),
  non_selected_attrs: ZList(String),
  class_attr: String,
  sub_dataset: ZList(Dict(String, String)),
) -> ZList(Dict(String, String)) {
  let grouped_by_class =
    ut_zlist.group_by(sub_dataset, ut_res.unsafe_get(_, class_attr))
  case zlist.count(grouped_by_class) {
    1 -> same_class(rule, class_attr, sub_dataset)
    _ ->
      case zlist.is_empty(non_selected_attrs) {
        True -> exhausted_attributes(rule, class_attr, grouped_by_class)
        False -> {
          let #(entropy, dataset_size) =
            entropy_with_size(sub_dataset, class_attr)
          let next_selected_attr =
            non_selected_attrs
            |> ut_zlist.max_by(fn(feature) {
              entropy
              -. feature_entropy(sub_dataset, class_attr, feature, dataset_size)
            })
            |> ut_res.unsafe_res
          let next_non_selected_attrs =
            zlist.filter(non_selected_attrs, fn(attr) {
              attr != next_selected_attr
            })
          sub_dataset
          |> ut_zlist.group_by(ut_res.unsafe_get(_, next_selected_attr))
          |> zlist.flat_map(fn(t) {
            let #(feature_val, sub_group) = t
            let next_rule = dict.insert(rule, next_selected_attr, feature_val)
            unfold_rule(
              next_rule,
              next_non_selected_attrs,
              class_attr,
              sub_group,
            )
          })
        }
      }
  }
}

pub fn decision_tree(
  dataset: ZList(Dict(String, String)),
  attributes: ZList(String),
  class: String,
) -> ZList(Dict(String, String)) {
  unfold_rule(dict.new(), attributes, class, dataset)
}

pub fn classifier(
  dataset: ZList(Dict(String, String)),
  discrete_attributes: ZList(String),
  class: String,
) -> fn(Dict(String, String)) -> String {
  let all_rules: ZList(Dict(String, String)) =
    decision_tree(dataset, discrete_attributes, class)
  fn(item) {
    all_rules
    |> zlist.find(fn(rule) {
      zlist.all(discrete_attributes, fn(feature) {
        case dict.get(rule, feature) {
          Error(Nil) -> True
          Ok(v) -> v == ut_res.unsafe_get(item, feature)
        }
      })
    })
    |> ut_res.unsafe_res
    |> ut_res.unsafe_get(class)
  }
}
