import emel/lazy/math/statistics as stats
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/int
import gleam/pair
import gleam_zlists.{ZList} as zlist

pub fn entropy_with_size(class_strs: ZList(String)) -> #(Float, Int) {
  let #(freqs, size) = ut_zlist.freqs_with_size(class_strs)
  let entropy =
    freqs
    |> zlist.map(pair.second)
    |> zlist.map(fn(x) { int.to_float(x) /. int.to_float(size) })
    |> stats.entropy
  #(entropy, size)
}

pub fn feature_entropy(
  feature_strs: ZList(String),
  class_strs: ZList(String),
  dataset_size: Int,
) -> Float {
  zlist.zip(feature_strs, class_strs)
  |> ut_zlist.group_by(pair.first)
  |> zlist.map(pair.second)
  |> zlist.map(zlist.unzip)
  |> zlist.map(pair.second)
  |> zlist.map(fn(strs) {
    let #(e, len) = entropy_with_size(strs)
    let p = int.to_float(len) /. int.to_float(dataset_size)
    p *. e
  })
  |> zlist.sum
}

pub fn information_gain(
  feature_strs: ZList(String),
  class_strs: ZList(String),
) -> Float {
  let #(entropy, dataset_size) = entropy_with_size(class_strs)
  entropy -. feature_entropy(feature_strs, class_strs, dataset_size)
}

pub fn exhausted_attributes(class_strs: ZList(String)) -> String {
  class_strs
  |> ut_zlist.freqs_with_size
  |> pair.first
  |> ut_zlist.max_by(fn(x) {
    x
    |> pair.second
    |> int.to_float
  })
  |> ut_res.unsafe_res
  |> pair.first
}
