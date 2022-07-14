import emel/ml/k_nearest_neighbors as knn
import gleeunit/should

pub fn k_nearest_neighbors_test() {
  knn.k_nearest_neighbors(
    [
      #([7.0, 7.0], "bad"),
      #([7.0, 4.0], "bad"),
      #([3.0, 4.0], "good"),
      #([1.0, 4.0], "good"),
    ],
    [3.0, 7.0],
    3,
  )
  |> should.equal([
    #([3.0, 4.0], "good"),
    #([1.0, 4.0], "good"),
    #([7.0, 7.0], "bad"),
  ])
}

pub fn classifier_test() {
  let f =
    knn.classifier(
      [
        #([7.0, 7.0], "bad"),
        #([7.0, 4.0], "bad"),
        #([3.0, 4.0], "good"),
        #([1.0, 4.0], "good"),
      ],
      3,
    )
  [3.0, 7.0]
  |> f
  |> should.equal("good")
}

pub fn predictor_test() {
  let f =
    knn.predictor(
      [
        #([0.0, 0.0, 0.0], 0.0),
        #([0.5, 0.5, 0.5], 1.5),
        #([1.0, 1.0, 1.0], 3.0),
        #([1.5, 1.5, 1.5], 4.5),
        #([2.0, 2.0, 2.0], 6.0),
        #([2.5, 2.5, 2.5], 7.5),
        #([3.0, 3.3, 3.0], 9.0),
      ],
      2,
    )
  [1.725, 1.725, 1.725]
  |> f
  |> should.equal(5.25)
}
