import emel/lazy/ml/decision_tree as lazy
import gleam_zlists as zlist
import gleeunit/should

fn risks() {
  [
    "high", "high", "moderate", "high", "low", "low", "high", "moderate", "low",
    "low", "high", "moderate", "low", "high",
  ]
  |> zlist.of_list
}

fn collaterals() {
  [
    "none", "none", "none", "none", "none", "adequate", "none", "adequate", "none",
    "adequate", "none", "none", "none", "none",
  ]
  |> zlist.of_list
}

fn incomes() {
  [
    "low", "moderate", "moderate", "low", "high", "high", "low", "high", "high",
    "high", "low", "moderate", "high", "moderate",
  ]
  |> zlist.of_list
}

fn depts() {
  [
    "high", "high", "low", "low", "low", "low", "low", "low", "low", "high", "high",
    "high", "high", "high",
  ]
  |> zlist.of_list
}

fn credit_histories() {
  [
    "bad", "unknown", "unknown", "unknown", "unknown", "unknown", "bad", "bad", "good",
    "good", "good", "good", "good", "bad",
  ]
  |> zlist.of_list
}

fn decisions() {
  [
    "No", "No", "Yes", "Yes", "Yes", "No", "Yes", "No", "Yes", "Yes", "Yes", "Yes",
    "Yes", "No",
  ]
  |> zlist.of_list
}

fn outlooks() {
  [
    "Sunny", "Sunny", "Overcast", "Rain", "Rain", "Rain", "Overcast", "Sunny", "Sunny",
    "Rain", "Sunny", "Overcast", "Overcast", "Rain",
  ]
  |> zlist.of_list
}

fn temperatures() {
  [
    "Hot", "Hot", "Hot", "Mild", "Cool", "Cool", "Cool", "Mild", "Cool", "Mild",
    "Mild", "Mild", "Hot", "Mild",
  ]
  |> zlist.of_list
}

fn humidities() {
  [
    "High", "High", "High", "High", "Normal", "Normal", "Normal", "High", "Normal",
    "Normal", "Normal", "High", "Normal", "High",
  ]
  |> zlist.of_list
}

fn winds() {
  [
    "Weak", "Strong", "Weak", "Weak", "Weak", "Strong", "Strong", "Weak", "Weak",
    "Weak", "Strong", "Strong", "Weak", "Strong",
  ]
  |> zlist.of_list
}

pub fn entropy_with_size_test() {
  risks()
  |> lazy.entropy_with_size
  |> should.equal(#(0.9657130652315666, 14))

  decisions()
  |> lazy.entropy_with_size
  |> should.equal(#(0.9402859586706309, 14))
}

pub fn feature_entropy_test() {
  lazy.feature_entropy(collaterals(), risks(), 14)
  |> should.equal(0.9083350856198091)

  lazy.feature_entropy(incomes(), risks(), 14)
  |> should.equal(0.5642953235635804)

  lazy.feature_entropy(depts(), risks(), 14)
  |> should.equal(0.9260282813042505)

  lazy.feature_entropy(credit_histories(), risks(), 14)
  |> should.equal(0.8836520493378552)

  lazy.feature_entropy(outlooks(), decisions(), 14)
  |> should.equal(0.6935361388961918)

  lazy.feature_entropy(temperatures(), decisions(), 14)
  |> should.equal(0.9110633930116763)

  lazy.feature_entropy(humidities(), decisions(), 14)
  |> should.equal(0.7884504573082896)

  lazy.feature_entropy(winds(), decisions(), 14)
  |> should.equal(0.8921589282623617)
}

pub fn information_gain_test() {
  [
    lazy.information_gain(collaterals(), risks()),
    lazy.information_gain(incomes(), risks()),
    lazy.information_gain(depts(), risks()),
    lazy.information_gain(credit_histories(), risks()),
    lazy.information_gain(outlooks(), decisions()),
    lazy.information_gain(temperatures(), decisions()),
    lazy.information_gain(humidities(), decisions()),
    lazy.information_gain(winds(), decisions()),
  ]
  |> should.equal([
    0.0573779796117575, 0.40141774166798627, 0.039684783927316114, 0.0820610158937114,
    0.2467498197744391, 0.029222565658954647, 0.15183550136234136, 0.04812703040826927,
  ])
}
