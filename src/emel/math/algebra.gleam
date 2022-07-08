import gleam_zlists.{ZList} as zlist
import emel/help/utils

fn lazy_first_minor(
  matrix: ZList(ZList(Float)),
  i: Int,
  j: Int,
) -> ZList(ZList(Float)) {
  matrix
  |> utils.delete_at(i)
  |> zlist.map(fn(zl) { utils.delete_at(zl, j) })
}

pub fn first_minor(
  matrix: List(List(Float)),
  i: Int,
  j: Int,
) -> List(List(Float)) {
  matrix
  |> utils.to_zlist_of_zlists
  |> lazy_first_minor(i, j)
  |> utils.to_list_of_lists
}
