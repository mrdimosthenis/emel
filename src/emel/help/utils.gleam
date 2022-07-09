import gleam/pair
import gleam_zlists.{ZList} as zlist

pub fn unsafe(f: fn(a) -> Result(b, _)) -> fn(a) -> b {
  fn(x) {
    assert Ok(res) = f(x)
    res
  }
}

pub fn unsafe2(f: fn(a, b) -> Result(c, _)) -> fn(a, b) -> c {
  fn(x, y) {
    assert Ok(res) = f(x, y)
    res
  }
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

pub fn delete_at(zl: ZList(a), i: Int) -> ZList(a) {
  zl
  |> zlist.with_index
  |> zlist.filter(fn(t) { pair.second(t) != i })
  |> zlist.map(pair.first)
}

pub fn replace_at(zl: ZList(a), i: Int, elem: a) -> ZList(a) {
  zl
  |> zlist.with_index
  |> zlist.map(fn(t) {
    let #(el, index) = t
    case index == i {
      True -> elem
      False -> el
    }
  })
}
