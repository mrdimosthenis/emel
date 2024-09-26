import emel/lazy/ml/logistic_regression as lazy
import gleam_zlists as zlist
import gleeunit/should

pub fn classifier_test() {
  let x = zlist.of_list([0.0, 0.0])
  let y = zlist.of_list([0.0, 1.0])
  let z = zlist.of_list([1.0, 0.0])
  let w = zlist.of_list([1.0, 1.0])
  let dataset =
    [#(x, False), #(y, False), #(z, False), #(w, True)]
    |> zlist.of_list
  let f = lazy.classifier(dataset, 0.5, 0.001, 100, 10_000)
  should.equal(f(x), False)
  should.equal(f(y), False)
  should.equal(f(z), False)
  should.equal(f(w), True)
}
