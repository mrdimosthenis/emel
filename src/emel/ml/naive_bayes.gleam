//// A simple _probabilistic classifier_ based on applying _Bayes' theorem_
//// with naive independence assumptions between the features.
//// It makes classifications using the maximum _posteriori_ decision rule in a Bayesian setting.

import emel/lazy/ml/naive_bayes as lazy
import gleam/map.{Map}
import gleam_zlists as zlist

/// Returns the function that classifies an item by using the _Naive Bayes Algorithm_.
///
/// ```erlang
/// Data = [
///   #{"outlook" => "Sunny", "temperature" => "Hot", "humidity" => "High", "wind" => "Weak", "decision" => "No"},
///   #{"outlook" => "Sunny", "temperature" => "Hot", "humidity" => "High", "wind" => "Strong", "decision" => "No"},
///   #{"outlook" => "Overcast", "temperature" => "Hot", "humidity" => "High", "wind" => "Weak", "decision" => "Yes"},
///   #{"outlook" => "Rain", "temperature" => "Mild", "humidity" => "High", "wind" => "Weak", "decision" => "Yes"},
///   #{"outlook" => "Rain", "temperature" => "Cool", "humidity" => "Normal", "wind" => "Weak", "decision" => "Yes"},
///   #{"outlook" => "Rain", "temperature" => "Cool", "humidity" => "Normal", "wind" => "Strong", "decision" => "No"},
///   #{"outlook" => "Overcast", "temperature" => "Cool", "humidity" => "Normal", "wind" => "Strong", "decision" => "Yes"},
///   #{"outlook" => "Sunny", "temperature" => "Mild", "humidity" => "High", "wind" => "Weak", "decision" => "No"},
///   #{"outlook" => "Sunny", "temperature" => "Cool", "humidity" => "Normal", "wind" => "Weak", "decision" => "Yes"},
///   #{"outlook" => "Rain", "temperature" => "Mild", "humidity" => "Normal", "wind" => "Weak", "decision" => "Yes"},
///   #{"outlook" => "Sunny", "temperature" => "Mild", "humidity" => "Normal", "wind" => "Strong", "decision" => "Yes"},
///   #{"outlook" => "Overcast", "temperature" => "Mild", "humidity" => "High", "wind" => "Strong", "decision" => "Yes"},
///   #{"outlook" => "Overcast", "temperature" => "Hot", "humidity" => "Normal", "wind" => "Weak", "decision" => "Yes"},
///   #{"outlook" => "Rain", "temperature" => "Mild", "humidity" => "High", "wind" => "Strong", "decision" => "No"}
/// ],
/// Features = ["outlook", "temperature", "humidity", "wind"],
/// Class = "decision",
/// F = emel@ml@naive_bayes:classifier(Data, Features, Class),
/// F(#{"outlook" => "Sunny", "temperature" => "Mild", "humidity" => "Normal", "wind" => "Strong"}).
/// % "Yes"
/// ```
pub fn classifier(
  data: List(Map(String, String)),
  features: List(String),
  class: String,
) -> fn(Map(String, String)) -> String {
  lazy.classifier(
    zlist.of_list(data),
    zlist.of_list(features),
    class,
  )
}
