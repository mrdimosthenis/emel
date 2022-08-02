import emel/ml/perceptron
import gleeunit/should

pub fn classifier_test() {
  let f0 =
    [
      #([0.0, 0.0], False),
      #([0.0, 1.0], True),
      #([1.0, 0.0], True),
      #([1.0, 1.0], True),
    ]
    |> perceptron.classifier(0.01, 0.1, 100)
  should.equal(f0([0.0, 0.0]), False)
  should.equal(f0([0.0, 1.0]), True)
  should.equal(f0([1.0, 0.0]), True)
  should.equal(f0([1.0, 1.0]), True)

  let f1 =
    [
      #([0.0, 0.0], False),
      #([0.0, 1.0], False),
      #([1.0, 0.0], False),
      #([1.0, 1.0], True),
    ]
    |> perceptron.classifier(0.01, 0.1, 100)
  should.equal(f1([0.0, 0.0]), False)
  should.equal(f1([0.0, 1.0]), False)
  should.equal(f1([1.0, 0.0]), False)
  should.equal(f1([1.0, 1.0]), True)

  let f2 =
    [
      #([0.0, 0.1], True),
      #([0.3, 0.2], False),
      #([0.2, 0.3], True),
      #([0.3, 0.4], True),
      #([0.4, 0.3], False),
      #([0.5, 0.5], False),
      #([0.5, 0.6], True),
      #([0.1, 0.2], True),
      #([0.0, 0.0], False),
      #([0.1, 0.0], False),
      #([0.2, 0.1], False),
      #([0.6, 0.7], True),
    ]
    |> perceptron.classifier(0.5, 0.001, 100)
  should.equal(f2([0.55, 0.35]), False)
}
