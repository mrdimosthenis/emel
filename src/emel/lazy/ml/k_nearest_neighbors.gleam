import emel/utils/min_sorted_zlist as mszl
import emel/lazy/math/geometry
import gleam/pair
import gleam_zlists.{ZList} as zlist

pub fn k_nearest_neighbors(
  dataset: ZList(#(ZList(Float), a)),
  item: ZList(Float),
  k: Int,
) -> ZList(#(ZList(Float), a)) {
  dataset
  |> zlist.reduce(
    mszl.new(k),
    fn(el, acc) {
      let weight =
        el
        |> pair.first
        |> geometry.euclidean_distance(item)
      mszl.updated(acc, #(el, weight))
    },
  )
  |> mszl.extract
}
