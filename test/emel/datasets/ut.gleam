import gleam/dict.{type Dict}
import gleam_zlists.{type ZList} as zlist

pub fn merge_attr(
  dataset: ZList(Dict(String, String)),
  attr: String,
  attr_vals: ZList(String),
) -> ZList(Dict(String, String)) {
  dataset
  |> zlist.zip(attr_vals)
  |> zlist.map(fn(t) {
    let #(m, s) = t
    dict.insert(m, attr, s)
  })
}
