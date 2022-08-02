import emel/lazy/ml/neural_network as lazy
import gleam_zlists as zlist
import gleeunit/should

pub fn classifier_test() {
  let x = zlist.of_list([8.0, 0.0, 0.0])
  let y = zlist.of_list([0.0, 9.0, 0.0])
  let z = zlist.of_list([0.0, 0.0, 9.0])
  let dataset =
    [#(z, "z"), #(x, "x"), #(y, "y")]
    |> zlist.of_list
  let inner_layers = zlist.singleton(4)
  let f = lazy.classifier(dataset, inner_layers, 0.99, 0.15, 25, 100)
  should.equal(f(x), "x")
  should.equal(f(y), "y")
  should.equal(f(z), "z")
}
