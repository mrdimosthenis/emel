import emel/math/statistics
import gleeunit/should

pub fn entropy_test() {
  [1.0]
  |> statistics.entropy
  |> should.equal(0.0)

  [0.5, 0.5]
  |> statistics.entropy
  |> should.equal(1.0)

  [0.999, 0.001]
  |> statistics.entropy
  |> should.equal(0.011407757737461138)

  [0.25, 0.25, 0.25, 0.25]
  |> statistics.entropy
  |> should.equal(1.0)

  [0.8, 0.05, 0.05, 0.1]
  |> statistics.entropy
  |> should.equal(0.5109640474436812)
}
