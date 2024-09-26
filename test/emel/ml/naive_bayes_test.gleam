import emel/datasets/decision
import emel/ml/naive_bayes
import gleam/dict
import gleam_zlists as zlist
import gleeunit/should

pub fn classifier_test() {
  let f =
    decision.dataset()
    |> zlist.to_list
    |> naive_bayes.classifier(
      ["outlook", "temperature", "humidity", "wind"],
      "decision",
    )

  let item1 =
    dict.from_list([
      #("outlook", "Sunny"),
      #("temperature", "Mild"),
      #("humidity", "Normal"),
      #("wind", "Strong"),
    ])
  let item2 =
    dict.from_list([
      #("outlook", "Overcast"),
      #("temperature", "Mild"),
      #("humidity", "Normal"),
      #("wind", "Strong"),
    ])
  let item3 =
    dict.from_list([
      #("outlook", "Sunny"),
      #("temperature", "Hot"),
      #("humidity", "High"),
      #("wind", "Strong"),
    ])
  let item4 =
    dict.from_list([
      #("outlook", "Sunny"),
      #("temperature", "Mild"),
      #("humidity", "Normal"),
      #("wind", "Weak"),
    ])
  let item5 =
    dict.from_list([
      #("outlook", "Sunny"),
      #("temperature", "Mild"),
      #("humidity", "Normal"),
      #("wind", "Weak"),
    ])
  let item6 =
    dict.from_list([
      #("outlook", "Overcast"),
      #("temperature", "Mild"),
      #("humidity", "High"),
      #("wind", "Strong"),
    ])
  let item7 =
    dict.from_list([
      #("outlook", "Sunny"),
      #("temperature", "Cool"),
      #("humidity", "High"),
      #("wind", "Strong"),
    ])
  let item8 =
    dict.from_list([
      #("outlook", "Rain"),
      #("temperature", "Mild"),
      #("humidity", "Normal"),
      #("wind", "Weak"),
    ])

  should.equal(f(item1), "Yes")
  should.equal(f(item2), "Yes")
  should.equal(f(item3), "No")
  should.equal(f(item4), "Yes")
  should.equal(f(item5), "Yes")
  should.equal(f(item6), "Yes")
  should.equal(f(item7), "No")
  should.equal(f(item8), "Yes")
}
