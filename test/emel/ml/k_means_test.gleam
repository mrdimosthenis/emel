import emel/lazy/ml/k_means as lazy
import emel/utils/zlist as ut_zlist
import gleam_zlists as zlist
import gleeunit/should

pub fn clusters_test() {
  [[1.0, 1.0], [2.0, 1.0], [4.0, 3.0], [5.0, 4.0]]
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.clusters(2, 1000)
  |> zlist.map(ut_zlist.to_list_of_lists)
  |> zlist.to_list
  |> should.equal([[[1.0, 1.0], [2.0, 1.0]], [[4.0, 3.0], [5.0, 4.0]]])

  [
    [0.0, 0.0],
    [4.0, 4.0],
    [9.0, 9.0],
    [4.3, 4.3],
    [9.9, 9.9],
    [4.4, 4.4],
    [0.1, 0.1],
  ]
  |> ut_zlist.to_zlist_of_zlists
  |> lazy.clusters(3, 1000)
  |> zlist.map(ut_zlist.to_list_of_lists)
  |> zlist.to_list
  |> should.equal([
    [[0.1, 0.1], [0.0, 0.0]],
    [[4.0, 4.0], [4.3, 4.3], [4.4, 4.4]],
    [[9.9, 9.9], [9.0, 9.0]],
  ])
}

pub fn classifier_test() {
  let f =
    [
      [0.0, 0.0],
      [4.0, 4.0],
      [9.0, 9.0],
      [4.3, 4.3],
      [9.9, 9.9],
      [4.4, 4.4],
      [0.1, 0.1],
    ]
    |> ut_zlist.to_zlist_of_zlists
    |> lazy.classifier(3, 1000)

  [0.1, 0.1]
  |> zlist.of_list
  |> f
  |> should.equal(0)

  [9.5, 9.5]
  |> zlist.of_list
  |> f
  |> should.equal(2)

  [0.6, 0.6]
  |> zlist.of_list
  |> f
  |> should.equal(0)

  [4.7, 4.7]
  |> zlist.of_list
  |> f
  |> should.equal(1)
}
