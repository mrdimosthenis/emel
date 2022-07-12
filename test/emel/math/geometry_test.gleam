import emel/math/geometry
import gleeunit/should

pub fn dot_ptoduct_test() {
  geometry.dot_product([-4.0, -9.0], [-1.0, 2.0])
  |> should.equal(-14.0)

  geometry.dot_product([1.0, 2.0, 3.0], [4.0, -5.0, 6.0])
  |> should.equal(12.0)
}

pub fn euclidean_distance_test() {
  geometry.euclidean_distance([2.0, -1.0], [-2.0, 2.0])
  |> should.equal(5.0)

  geometry.euclidean_distance([0.0, 3.0, 4.0, 5.0], [7.0, 6.0, 3.0, -1.0])
  |> should.equal(9.746794344808963)
}
