import emel/ml/k_nearest_neighbors as knn
import gleeunit/should

pub fn k_nearest_neighbors_test() {
  knn.k_nearest_neighbors(
    [3.0, 7.0],
    [
      #([7.0, 7.0], "bad"),
      #([7.0, 4.0], "bad"),
      #([3.0, 4.0], "good"),
      #([1.0, 4.0], "good"),
    ],
    3,
  )
  |> should.equal([
    #([3.0, 4.0], "good"),
    #([1.0, 4.0], "good"),
    #([7.0, 7.0], "bad"),
  ])
}
