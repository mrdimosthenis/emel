import emel/lazy/math/statistics as stats
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/dict.{type Dict}
import gleam/int
import gleam_zlists.{type ZList} as zlist

fn prior_probability(
  observations: ZList(Dict(String, String)),
  attribute: String,
  value: String,
) -> Float {
  observations
  |> zlist.map(ut_res.unsafe_get(_, attribute))
  |> stats.classical_probability(value)
}

fn probability_b_given_a(
  observations: ZList(Dict(String, String)),
  attribute_b: String,
  value_b: String,
  attribute_a: String,
  value_a: String,
) -> Float {
  observations
  |> zlist.filter(fn(m) { ut_res.unsafe_get(m, attribute_a) == value_a })
  |> prior_probability(attribute_b, value_b)
}

pub fn classifier(
  dataset: ZList(Dict(String, String)),
  discrete_attributes: ZList(String),
  class: String,
) -> fn(Dict(String, String)) -> String {
  let class_values = zlist.map(dataset, ut_res.unsafe_get(_, class))
  let uniq_class_values: ZList(String) = ut_zlist.uniq(class_values)
  let #(class_freqs, dataset_size) = ut_zlist.freqs_with_size(class_values)
  let class_probabilities: Dict(String, Float) =
    class_freqs
    |> zlist.map(fn(t) {
      let #(class_val, freq) = t
      let probability = int.to_float(freq) /. int.to_float(dataset_size)
      #(class_val, probability)
    })
    |> zlist.to_list
    |> dict.from_list
  fn(item) {
    uniq_class_values
    |> ut_zlist.max_by(fn(value_a) {
      let prior_probability =
        discrete_attributes
        |> zlist.to_list
        |> dict.take(item, _)
        |> dict.to_list
        |> zlist.of_list
        |> zlist.reduce(1.0, fn(t, acc) {
          let #(attribute_b, value_b) = t
          acc
          *. probability_b_given_a(
            dataset,
            attribute_b,
            value_b,
            class,
            value_a,
          )
        })
      prior_probability *. ut_res.unsafe_get(class_probabilities, value_a)
    })
    |> ut_res.unsafe_res
  }
}
