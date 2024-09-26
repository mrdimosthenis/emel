import gleam/float
import gleam/int
import gleam_zlists.{type ZList} as zlist

@external(erlang, "math", "log")
pub fn log(x: Float) -> Float

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
    zlist.reduce(observations, #(0.0, 0.0), fn(ev, acc) {
      let #(numer, denom) = acc
      let next_numer = case ev == event {
        True -> numer +. 1.0
        False -> numer
      }
      let next_denom = denom +. 1.0
      #(next_numer, next_denom)
    })
  numerator /. denominator
}

pub fn mean_absolute_error(
  predictions: ZList(Float),
  observations: ZList(Float),
) -> Float {
  let #(numerator, denominator) =
    zlist.reduce(zlist.zip(predictions, observations), #(0.0, 0.0), fn(p, acc) {
      let #(v1, v2) = p
      let #(numer, denom) = acc
      let next_numer = numer +. float.absolute_value(v1 -. v2)
      let next_denom = denom +. 1.0
      #(next_numer, next_denom)
    })
  numerator /. denominator
}
