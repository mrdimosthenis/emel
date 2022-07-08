import emel/math/algebra
import gleeunit/should

pub fn first_minor_test() {
  [[1.0, 4.0, 7.0], [3.0, 0.0, 5.0], [-1.0, 9.0, 11.0]]
  |> algebra.first_minor(1, 2)
  |> should.equal([[1.0, 4.0], [-1.0, 9.0]])
}
