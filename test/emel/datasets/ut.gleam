import gleam/map.{Map}
import gleam_zlists.{ZList} as zlist

pub fn merge_attr(
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
