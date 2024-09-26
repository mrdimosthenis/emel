//// Uses a _decision tree_ to go from _observations_ about a point (represented in the branches)
//// to conclusions about the point's discrete target value (represented in the leaves).

import emel/lazy/ml/decision_tree as lazy
import gleam/dict.{type Dict}
import gleam_zlists as zlist

/// The expanded _decision tree_ as a list of maps.
/// It gets created with the _ID3 Algorithm_
/// for the provided `data` and the specified `features`.
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
/// emel@ml@decision_tree:decision_tree(Data, Features, Class).
/// % [
/// %   #{"outlook" => "Overcast", "decision" => "Yes"},
/// %   #{"outlook" => "Rain", "wind" => "Strong", "decision" => "No"},
/// %   #{"outlook" => "Rain", "wind" => "Weak", "decision" => "Yes"},
/// %   #{"humidity" => "High", "outlook" => "Sunny", "decision" => "No"},
/// %   #{"humidity" => "Normal", "outlook" => "Sunny", "decision" => "Yes"}
/// % ]
/// ```
pub fn decision_tree(
  data: List(Dict(String, String)),
  features: List(String),
  class: String,
) -> List(Dict(String, String)) {
  lazy.decision_tree(zlist.of_list(data), zlist.of_list(features), class)
  |> zlist.to_list
}

/// Returns the function that classifies a point by using the _ID3 Algorithm_.
///
/// ```erlang
/// Data = [
///   #{"collateral" => "none", "income" => "low", "debt" => "high", "credit_history" => "bad", "risk" => "high"},
///   #{"collateral" => "none", "income" => "moderate", "debt" => "high", "credit_history" => "unknown", "risk" => "high"},
///   #{"collateral" => "none", "income" => "moderate", "debt" => "low", "credit_history" => "unknown", "risk" => "moderate"},
///   #{"collateral" => "none", "income" => "low", "debt" => "low", "credit_history" => "unknown", "risk" => "high"},
///   #{"collateral" => "none", "income" => "high", "debt" => "low", "credit_history" => "unknown", "risk" => "low"},
///   #{"collateral" => "adequate", "income" => "high", "debt" => "low", "credit_history" => "unknown", "risk" => "low"},
///   #{"collateral" => "none", "income" => "low", "debt" => "low", "credit_history" => "bad", "risk" => "high"},
///   #{"collateral" => "adequate", "income" => "high", "debt" => "low", "credit_history" => "bad", "risk" => "moderate"},
///   #{"collateral" => "none", "income" => "high", "debt" => "low", "credit_history" => "good", "risk" => "low"},
///   #{"collateral" => "adequate", "income" => "high", "debt" => "high", "credit_history" => "good", "risk" => "low"},
///   #{"collateral" => "none", "income" => "low", "debt" => "high", "credit_history" => "good", "risk" => "high"},
///   #{"collateral" => "none", "income" => "moderate", "debt" => "high", "credit_history" => "good", "risk" => "moderate"},
///   #{"collateral" => "none", "income" => "high", "debt" => "high", "credit_history" => "good", "risk" => "low"},
///   #{"collateral" => "none", "income" => "moderate", "debt" => "high", "credit_history" => "bad", "risk" => "high"}
/// ],
/// Features = ["collateral", "income", "debt", "credit_history"],
/// Class = "risk",
/// F = emel@ml@decision_tree:classifier(Data, Features, Class),
/// F(#{"collateral" => "none", "income" => "high", "debt" => "low", "credit_history" => "good"}).
/// % "low"
/// ```
pub fn classifier(
  data: List(Dict(String, String)),
  features: List(String),
  class: String,
) -> fn(Dict(String, String)) -> String {
  lazy.classifier(zlist.of_list(data), zlist.of_list(features), class)
}
