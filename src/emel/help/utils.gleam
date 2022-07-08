import gleam/pair
import gleam_zlists.{ZList} as zlist

pub fn delete_at(zl: ZList(a), i: Int) -> ZList(a) {
  zl
  |> zlist.with_index
  |> zlist.filter(fn(t) { pair.second(t) != i })
  |> zlist.map(pair.first)
}

pub fn to_list_of_lists(zl: ZList(ZList(a))) -> List(List(a)) {
  zl
  |> zlist.map(zlist.to_list)
  |> zlist.to_list
}

pub fn to_zlist_of_zlists(ls: List(List(a))) -> ZList(ZList(a)) {
  ls
  |> zlist.of_list
  |> zlist.map(zlist.of_list)
}
