import emel/lazy/math/geometry
import emel/lazy/math/statistics
import gleam_zlists.{ZList} as zlist

fn updated_weights(
  ws: ZList(Float),
  xs: ZList(ZList(Float)),
  ys: ZList(Float),
  a: Float,
) -> ZList(Float) {
  zlist.reduce(
    zlist.zip(xs, ys),
    ws,
    fn(p, acc) {
      let #(x, y) = p
      let y_hat = geometry.dot_product(acc, x)
      let common_factor = a *. { y -. y_hat }
      zlist.zip(acc, x)
      |> zlist.map(fn(t) {
        let #(wi, xi) = t
        wi +. common_factor *. xi
      })
    },
  )
}

fn iterate(
  ws: ZList(Float),
  xs: ZList(ZList(Float)),
  ys: ZList(Float),
  a: Float,
  err_thres: Float,
  countdown: Int,
) -> ZList(Float) {
  case countdown {
    0 -> ws
    _ -> {
      let new_ws = updated_weights(ws, xs, ys, a)
      let mean_abs_err =
        xs
        |> zlist.map(fn(x) { geometry.dot_product(new_ws, x) })
        |> statistics.mean_absolute_error(ys)
      case mean_abs_err <. err_thres {
        True -> new_ws
        False -> iterate(new_ws, xs, ys, a, err_thres, countdown - 1)
      }
    }
  }
}

pub fn classifier(
  dataset: ZList(#(ZList(Float), Bool)),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
) -> fn(ZList(Float)) -> Bool {
  let #(xs, bools) = zlist.unzip(dataset)
  let ys =
    zlist.map(
      bools,
      fn(b) {
        case b {
          True -> 1.0
          False -> 0.0
        }
      },
    )
  let zeros = zlist.iterate(0.0, fn(_) { 0.0 })
  let weights: ZList(Float) =
    iterate(zeros, xs, ys, learning_rate, error_threshold, max_iterations)
  fn(item) {
    let y_hat =
      item
      |> zlist.cons(1.0)
      |> geometry.dot_product(weights)
    y_hat >. 0.5
  }
}
