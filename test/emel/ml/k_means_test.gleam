import emel/ml/k_means
import gleam/list
import gleam/set.{Set}
import gleeunit/should

fn to_set_of_sets(ls: List(List(List(Float)))) -> Set(Set(List(Float))) {
  ls
  |> list.map(set.from_list)
  |> set.from_list
}

pub fn clusters_test() {
  [[1.0, 1.0], [2.0, 1.0], [4.0, 3.0], [5.0, 4.0]]
  |> k_means.clusters(2)
  |> to_set_of_sets
  |> should.equal(to_set_of_sets([
    [[1.0, 1.0], [2.0, 1.0]],
    [[4.0, 3.0], [5.0, 4.0]],
  ]))
  // [
  //   [0.0, 0.0],
  //   [4.0, 4.0],
  //   [9.0, 9.0],
  //   [4.3, 4.3],
  //   [9.9, 9.9],
  //   [4.4, 4.4],
  //   [0.1, 0.1],
  // ]
  // |> k_means.clusters(3)
  // |> to_set_of_sets
  // |> should.equal(to_set_of_sets([
  //   [[0.1, 0.1], [0.0, 0.0]],
  //   [[4.3, 4.3], [4.0, 4.0], [4.4, 4.4]],
  //   [[9.9, 9.9], [9.0, 9.0]],
  // ]))
}
