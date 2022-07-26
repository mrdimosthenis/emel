import emel/lazy/math/statistics as stats
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/int
import gleam/map.{Map}
import gleam/pair
import gleam_zlists.{ZList} as zlist

fn unsafe_get(m: Map(a, b), k: a) -> b {
  m
  |> map.get(k)
  |> ut_res.unsafe_res
}

pub fn entropy_with_size(
  dataset: ZList(Map(String, String)),
  class_attr: String,
) -> #(Float, Int) {
  let #(freqs, size) =
    dataset
    |> zlist.map(unsafe_get(_, class_attr))
    |> ut_zlist.freqs_with_size
  let entropy =
    freqs
    |> zlist.map(pair.second)
    |> zlist.map(fn(x) { int.to_float(x) /. int.to_float(size) })
    |> stats.entropy
  #(entropy, size)
}

pub fn feature_entropy(
  dataset: ZList(Map(String, String)),
  class_attr: String,
  feature: String,
  dataset_size: Int,
) -> Float {
  dataset
  |> ut_zlist.group_by(unsafe_get(_, feature))
  |> zlist.map(pair.second)
  |> zlist.map(fn(sub_dataset) {
    let #(e, len) = entropy_with_size(sub_dataset, class_attr)
    let p = int.to_float(len) /. int.to_float(dataset_size)
    p *. e
  })
  |> zlist.sum
}

fn same_class(
  rule: Map(String, String),
  class_attr: String,
  sub_dataset: ZList(Map(String, String)),
) -> ZList(Map(String, String)) {
  sub_dataset
  |> zlist.head
  |> ut_res.unsafe_res
  |> unsafe_get(class_attr)
  |> map.insert(rule, class_attr, _)
  |> zlist.singleton
}

fn exhausted_attributes(
  rule: Map(String, String),
  class_attr: String,
  grouped_by_class: ZList(#(String, ZList(Map(String, String)))),
) -> ZList(Map(String, String)) {
  grouped_by_class
  |> ut_zlist.max_by(fn(t) {
    t
    |> pair.second
    |> zlist.count
    |> int.to_float
  })
  |> ut_res.unsafe_res
  |> pair.first
  |> map.insert(rule, class_attr, _)
  |> zlist.singleton
}

fn unfold_rule(
  rule: Map(String, String),
  non_selected_attrs: ZList(String),
  class_attr: String,
  sub_dataset: ZList(Map(String, String)),
) -> ZList(Map(String, String)) {
  let grouped_by_class =
    ut_zlist.group_by(sub_dataset, unsafe_get(_, class_attr))
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
              entropy -. feature_entropy(
                sub_dataset,
                class_attr,
                feature,
                dataset_size,
              )
            })
            |> ut_res.unsafe_res
          let next_non_selected_attrs =
            zlist.filter(
              non_selected_attrs,
              fn(attr) { attr != next_selected_attr },
            )
          sub_dataset
          |> ut_zlist.group_by(unsafe_get(_, next_selected_attr))
          |> zlist.flat_map(fn(t) {
            let #(feature_val, sub_group) = t
            let next_rule = map.insert(rule, next_selected_attr, feature_val)
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
  dataset: ZList(Map(String, String)),
  attributes: ZList(String),
  class: String,
) -> ZList(Map(String, String)) {
  unfold_rule(map.new(), attributes, class, dataset)
}

pub fn classifier(
  dataset: ZList(Map(String, String)),
  discrete_attributes: ZList(String),
  class: String,
) -> fn(Map(String, String)) -> String {
  let all_rules = decision_tree(dataset, discrete_attributes, class)
  fn(item) {
    all_rules
    |> zlist.find(fn(rule) {
      zlist.all(
        discrete_attributes,
        fn(feature) {
          case map.get(rule, feature) {
            Error(Nil) -> True
            Ok(v) -> v == unsafe_get(item, feature)
          }
        },
      )
    })
    |> ut_res.unsafe_res
    |> unsafe_get(class)
  }
}
