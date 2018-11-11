defmodule Emel do
  @moduledoc """
  [Turn data into functions](https://github.com/mrdimosthenis/emel)! A simple and functional **machine learning** library written in **elixir**.

  ```elixir
  # set up the aliases for the module
  alias Ml.KNearestNeighbors, as: KNN

  dataset = [
    %{"x1" => 0.0, "x2" => 0.0, "x3" => 0.0, "y" => 0.0},
    %{"x1" => 0.5, "x2" => 0.5, "x3" => 0.5, "y" => 1.5},
    %{"x1" => 1.0, "x2" => 1.0, "x3" => 1.0, "y" => 3.0},
    %{"x1" => 1.5, "x2" => 1.5, "x3" => 1.5, "y" => 4.5},
    %{"x1" => 2.0, "x2" => 2.0, "x3" => 2.0, "y" => 6.0},
    %{"x1" => 2.5, "x2" => 2.5, "x3" => 2.5, "y" => 7.5},
    %{"x1" => 3.0, "x2" => 3.3, "x3" => 3.0, "y" => 9.0}
  ]

  # turn the dataset into a function
  f = KNN.predictor(dataset, ["x1", "x2", "x3"], "y", 2)

  # make predictions
  f.(%{"x1" => 1.725, "x2" => 1.725, "x3" => 1.725})
  # 5.25
  ```

  ### Implemented Algorithms

  * [Linear Regression](https://hexdocs.pm/emel/0.1.1/Ml.LinearRegression.html)
  * [K Nearest Neighbors](https://hexdocs.pm/emel/0.1.1/Ml.KNearestNeighbors.html)
  * [Decision Tree](https://hexdocs.pm/emel/0.1.1/Ml.DecisionTree.html)
  * [Naive Bayes](https://hexdocs.pm/emel/0.1.1/Ml.NaiveBayes.html)
  * [K Means](https://hexdocs.pm/emel/0.1.1/Ml.KMeans.html)
  * [Perceptron](https://hexdocs.pm/emel/0.1.1/Ml.Perceptron.html)

  ```elixir
  alias Ml.DecisionTree, as: DecisionTree
  alias Help.Model, as: Mdl
  alias Math.Statistics, as: Stat

  dataset = [
    %{risk: "high", collateral: "none", income: "low", debt: "high", credit_history: "bad"},
    %{risk: "high", collateral: "none", income: "moderate", debt: "high", credit_history: "unknown"},
    %{risk: "moderate", collateral: "none", income: "moderate", debt: "low", credit_history: "unknown"},
    %{risk: "high", collateral: "none", income: "low", debt: "low", credit_history: "unknown"},
    %{risk: "low", collateral: "none", income: "high", debt: "low", credit_history: "unknown"},
    %{risk: "low", collateral: "adequate", income: "high", debt: "low", credit_history: "unknown"},
    %{risk: "high", collateral: "none", income: "low", debt: "low", credit_history: "bad"},
    %{risk: "moderate", collateral: "adequate", income: "high", debt: "low", credit_history: "bad"},
    %{risk: "low", collateral: "none", income: "high", debt: "low", credit_history: "good"},
    %{risk: "low", collateral: "adequate", income: "high", debt: "high", credit_history: "good"},
    %{risk: "high", collateral: "none", income: "low", debt: "high", credit_history: "good"},
    %{risk: "moderate", collateral: "none", income: "moderate", debt: "high", credit_history: "good"},
    %{risk: "low", collateral: "none", income: "high", debt: "high", credit_history: "good"},
    %{risk: "high", collateral: "none", income: "moderate", debt: "high", credit_history: "bad"}
  ]

  {training_set, test_set} = Mdl.training_and_test_sets(dataset, 0.75)

  f = DecisionTree.classifier(training_set, [:collateral, :income, :debt, :credit_history], :risk)

  predictions = Enum.map(test_set, fn row -> f.(row) end)
  actual_values = Enum.map(test_set, fn %{risk: v} -> v end)
  Stat.similarity(predictions, actual_values)
  # 0.75
  ```

  ### Mathematics

  * [Algebra](https://hexdocs.pm/emel/0.1.1/Math.Algebra.html)
  * [Geometry](https://hexdocs.pm/emel/0.1.1/Math.Geometry.html)
  * [Statistics](https://hexdocs.pm/emel/0.1.1/Math.Statistics.html)

  ```elixir
  alias Ml.LinearRegression, as: LR
  alias Help.Model, as: Mdl
  alias Math.Statistics, as: Stat

  dataset = [
    %{x1: 1, x2: 1, y: -1},
    %{x1: 1, x2: 2, y: -1},
    %{x1: 1, x2: 3, y: -2},
    %{x1: 1, x2: 4, y: -4},
    %{x1: 2, x2: 1, y: 1},
    %{x1: 2, x2: 2, y: 1},
    %{x1: 2, x2: 3, y: 0},
    %{x1: 2, x2: 4, y: -1},
    %{x1: 3, x2: 1, y: 3},
    %{x1: 3, x2: 2, y: 2},
    %{x1: 3, x2: 3, y: 1},
    %{x1: 3, x2: 4, y: 0},
    %{x1: 4, x2: 1, y: 5},
    %{x1: 4, x2: 2, y: 4},
    %{x1: 4, x2: 3, y: 4},
    %{x1: 4, x2: 4, y: 3}
  ]

  {training_set, test_set} = Mdl.training_and_test_sets(dataset, 0.8)

  f = LR.predictor(training_set, [:x1, :x2], :y)

  predictions = Enum.map(test_set, fn row -> f.(row) end)
  actual_values = Enum.map(test_set, fn %{y: v} -> v end)
  Stat.mean_absolute_error(predictions, actual_values)
  # 0.5889423076923077
  ```

  """
end
