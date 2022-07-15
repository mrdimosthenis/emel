import gleam/map.{Map}
import gleam/pair
import gleam_zlists.{ZList} as zlist

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

pub fn avg(zl: ZList(Float)) -> Result(Float, Nil) {
  case zlist.uncons(zl) {
    Error(Nil) -> Error(Nil)
    Ok(#(hd, tl)) -> {
      let #(s, n) =
        zlist.reduce(
          tl,
          #(hd, 1.0),
          fn(x, acc) {
            let #(acc_s, acc_n) = acc
            #(acc_s +. x, acc_n +. 1.0)
          },
        )
      Ok(s /. n)
    }
  }
}

pub fn max_by(zl: ZList(a), f: fn(a) -> Float) -> Result(a, Nil) {
  case zlist.uncons(zl) {
    Error(Nil) -> Error(Nil)
    Ok(#(hd, tl)) ->
      tl
      |> zlist.reduce(
        #(hd, f(hd)),
        fn(el, acc) {
          let f_el = f(el)
          case f_el >. pair.second(acc) {
            True -> #(el, f_el)
            False -> acc
          }
        },
      )
      |> pair.first
      |> Ok
  }
}

pub fn abs_freqs(zl: ZList(a)) -> Map(a, Int) {
  zlist.reduce(
    zl,
    map.new(),
    fn(el, acc) {
      let new_group = case map.get(acc, el) {
        Ok(n) -> n + 1
        Error(Nil) -> 1
      }
      map.insert(acc, el, new_group)
    },
  )
}

pub fn rel_freqs(zl: ZList(a)) -> Map(a, Float) {
  let #(freqs, counter) =
    zlist.reduce(
      zl,
      #(map.new(), 0.0),
      fn(el, acc) {
        let #(acc_map, acc_counter) = acc
        let new_group = case map.get(acc_map, el) {
          Ok(n) -> n +. 1.0
          Error(Nil) -> 1.0
        }
        let new_acc_map = map.insert(acc_map, el, new_group)
        #(new_acc_map, acc_counter +. 1.0)
      },
    )
  map.map_values(freqs, fn(_, v) { v /. counter })
}
