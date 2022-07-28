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

pub fn magnitude_test() {
  [0.0, 2.0]
  |> geometry.magnitude
  |> should.equal(2.0)

  [6.0, 8.0]
  |> geometry.magnitude
  |> should.equal(10.0)

  [1.0, -2.0, 3.0]
  |> geometry.magnitude
  |> should.equal(3.7416573867739413)
}

pub fn nearest_neighbor_test() {
  [[0.0, 0.0], [0.0, 0.1], [1.0, 0.0], [1.0, 1.0]]
  |> geometry.nearest_neighbor([0.9, 0.0], _)
  |> should.equal([1.0, 0.0])
}

pub fn centroid_test() {
  [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]
  |> geometry.centroid
  |> should.equal([0.5, 0.5])
}
