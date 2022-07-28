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

pub fn classical_probability(observations: ZList(a), event: a) -> Float {
  let #(numerator, denominator) =
    zlist.reduce(
      observations,
      #(0.0, 0.0),
      fn(ev, acc) {
        let #(num, denom) = acc
        let next_num = case ev == event {
          True -> num +. 1.0
          False -> num
        }
        let next_denom = denom +. 1.0
        #(next_num, next_denom)
      },
    )
  numerator /. denominator
}
