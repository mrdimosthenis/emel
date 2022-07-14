import gleam/float
import gleam/int
import gleam_zlists.{ZList} as zlist

external fn log(Float) -> Float =
  "math" "log"

fn log_base(x: Float, b: Float) -> Float {
  log(x) /. log(b)
}

pub fn entropy(probability_values: ZList(Float)) -> Float {
  let b =
    probability_values
    |> zlist.count
    |> int.to_float
  probability_values
  |> zlist.map(fn(p) { float.negate(p) *. log_base(p, b) })
  |> zlist.sum
}
