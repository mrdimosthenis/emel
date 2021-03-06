  # emel
  
  [Turn data into functions](https://github.com/mrdimosthenis/emel)! A simple and functional **machine learning** library written in **elixir**.
  
  <a href="https://hexdocs.pm/emel/0.3.0/Emel.Ml.NeuralNetwork.html">![emel neural network](https://github.com/mrdimosthenis/emel/raw/master/resources/images/emel_nn.png)
  </a>

  ## Installation

  The package can be installed by adding `emel` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:emel, "~> 0.3.0"}
  ]
  end
  ```

  The docs can be found at [https://hexdocs.pm/emel/0.3.0](https://hexdocs.pm/emel/0.3.0).

  ## Usage

  ```elixir
  # set up the aliases for the module
  alias Emel.Ml.KNearestNeighbors, as: KNN

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

  * [Linear Regression](https://hexdocs.pm/emel/0.3.0/Emel.Ml.LinearRegression.html)
  * [K Nearest Neighbors](https://hexdocs.pm/emel/0.3.0/Emel.Ml.KNearestNeighbors.html)
  * [Decision Tree](https://hexdocs.pm/emel/0.3.0/Emel.Ml.DecisionTree.html)
  * [Naive Bayes](https://hexdocs.pm/emel/0.3.0/Emel.Ml.NaiveBayes.html)
  * [K Means](https://hexdocs.pm/emel/0.3.0/Emel.Ml.KMeans.html)
  * [Perceptron](https://hexdocs.pm/emel/0.3.0/Emel.Ml.Perceptron.html)
  * [Logistic Regression](https://hexdocs.pm/emel/0.3.0/Emel.Ml.LogisticRegression.html)
  * [Neural Network](https://hexdocs.pm/emel/0.3.0/Emel.Ml.NeuralNetwork.html)

  ```elixir
  alias Emel.Ml.DecisionTree, as: DecisionTree
  alias Emel.Help.Model, as: Mdl
  alias Emel.Math.Statistics, as: Stat

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

  * [Algebra](https://hexdocs.pm/emel/0.3.0/Emel.Math.Algebra.html)
  * [Geometry](https://hexdocs.pm/emel/0.3.0/Emel.Math.Geometry.html)
  * [Statistics](https://hexdocs.pm/emel/0.3.0/Emel.Math.Statistics.html)
  * [Calculus](https://hexdocs.pm/emel/0.3.0/Emel.Math.Calculus.html)
