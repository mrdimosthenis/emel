import gleam/map
import gleam/pair
import gleam/set
import gleam_zlists.{ZList} as zlist
import minigen

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

pub fn uniq(zl: ZList(a)) -> ZList(a) {
  zl
  |> zlist.reduce(set.new(), fn(x, acc) { set.insert(acc, x) })
  |> set.to_list
  |> zlist.of_list
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

pub fn min_by(zl: ZList(a), f: fn(a) -> Float) -> Result(a, Nil) {
  max_by(zl, fn(x) { 0.0 -. f(x) })
}

pub fn group_by(zl: ZList(a), f: fn(a) -> b) -> ZList(#(b, ZList(a))) {
  zl
  |> zlist.reduce(
    map.new(),
    fn(el, acc) {
      let k = f(el)
      let new_group = case map.get(acc, k) {
        Ok(group) -> zlist.cons(group, el)
        Error(Nil) -> zlist.singleton(el)
      }
      map.insert(acc, k, new_group)
    },
  )
  |> map.to_list
  |> zlist.of_list
}

pub fn freqs_with_size(zl: ZList(a)) -> #(ZList(#(a, Int)), Int) {
  let #(freqs, counter) =
    zlist.reduce(
      zl,
      #(map.new(), 0),
      fn(el, acc) {
        let #(acc_map, acc_counter) = acc
        let new_group = case map.get(acc_map, el) {
          Ok(n) -> n + 1
          Error(Nil) -> 1
        }
        let new_acc_map = map.insert(acc_map, el, new_group)
        #(new_acc_map, acc_counter + 1)
      },
    )
  let zfreqs =
    freqs
    |> map.to_list
    |> zlist.of_list
  #(zfreqs, counter)
}

pub fn shuffle(zl: ZList(a)) -> ZList(a) {
  zl
  |> zlist.to_list
  |> minigen.shuffled_list
  |> minigen.run
  |> zlist.of_list
}
