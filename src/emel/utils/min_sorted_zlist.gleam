import emel/utils/result as ut_res
import gleam/option.{type Option, None, Some}
import gleam_zlists.{type ZList} as zlist

pub fn new(size: Int) -> ZList(Option(#(_, Float))) {
  zlist.indices()
  |> zlist.take(size)
  |> zlist.map(fn(_) { None })
}

pub fn updated(
  mszl: ZList(Option(#(a, Float))),
  el_with_weight: #(a, Float),
) -> ZList(Option(#(a, Float))) {
  let #(_, weight) = el_with_weight
  let #(lt_ls, gt_zls) =
    zlist.split_while(mszl, fn(x) {
      case x {
        Some(#(_, w)) if weight >. w -> True
        _ -> False
      }
    })
  let lt_zls = zlist.of_list(lt_ls)
  case zlist.is_empty(gt_zls) {
    True -> mszl
    False ->
      gt_zls
      |> zlist.reverse
      |> zlist.tail
      |> ut_res.unsafe_res
      |> zlist.reverse
      |> zlist.cons(Some(el_with_weight))
      |> zlist.append(lt_zls, _)
  }
}

pub fn extract(mszl: ZList(Option(#(a, Float)))) -> ZList(a) {
  mszl
  |> zlist.take_while(option.is_some)
  |> zlist.map(fn(opt) {
    let assert Some(#(x, _)) = opt
    x
  })
}
