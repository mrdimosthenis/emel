defmodule Emel do
  @moduledoc ~S"""
  # Emel

  Turn data into functions! A simple and functional *machine learning* library written in *elixir*.

  ```

    ## Regression

    ### Linear Regression

    iex> # set up the aliases for the module
    ...> alias Ml.LinearRegression, as: LR
    ...>
    ...> # turn the dataset into a function
    ...>
    ...> dataset = [
    ...>   %{x1: 1, x2: 1, y: -1},
    ...>   %{x1: 1, x2: 2, y: -1},
    ...>   %{x1: 1, x2: 3, y: -2},
    ...>   %{x1: 1, x2: 4, y: -4},
    ...>   %{x1: 2, x2: 1, y: 1},
    ...>   %{x1: 2, x2: 2, y: 1},
    ...>   %{x1: 2, x2: 3, y: 0},
    ...>   %{x1: 2, x2: 4, y: -1},
    ...>   %{x1: 3, x2: 1, y: 3},
    ...>   %{x1: 3, x2: 2, y: 2},
    ...>   %{x1: 3, x2: 3, y: 1},
    ...>   %{x1: 3, x2: 4, y: 0},
    ...>   %{x1: 4, x2: 1, y: 5},
    ...>   %{x1: 4, x2: 2, y: 4},
    ...>   %{x1: 4, x2: 3, y: 4},
    ...>   %{x1: 4, x2: 4, y: 3}
    ...> ]
    ...>
    ...> f = LR.predictor(dataset, [:x1, :x2], :y)
    ...>
    ...> # make predictions
    ...> f.(%{x1: 4, x2: 2})
    4.237500000000001

    ### K Nearest Neighbors

    iex> alias Ml.KNearestNeighbors, as: KNN
    ...>
    ...> dataset = [
    ...>   %{x1: 0.0, x2: 0.0, x3: 0.0, y: 0.0},
    ...>   %{x1: 0.5, x2: 0.5, x3: 0.5, y: 1.5},
    ...>   %{x1: 1.0, x2: 1.0, x3: 1.0, y: 3.0},
    ...>   %{x1: 1.5, x2: 1.5, x3: 1.5, y: 4.5},
    ...>   %{x1: 2.0, x2: 2.0, x3: 2.0, y: 6.0},
    ...>   %{x1: 2.5, x2: 2.5, x3: 2.5, y: 7.5},
    ...>   %{x1: 3.0, x2: 3.3, x3: 3.0, y: 9.0}
    ...> ]
    ...>
    ...> f = KNN.predictor(dataset, [:x1, :x2, :x3], :y, 2)
    ...>
    ...> f.(%{x1: 1.725, x2: 1.725, x3: 1.725})
    5.25

    ## Classification

    ### Decision Tree

    iex> alias Ml.DecisionTree
    ...>
    ...> dataset = [
    ...>   %{outlook: "Sunny", temperature: "Hot", humidity: "High", wind: "Weak", decision: "No"},
    ...>   %{outlook: "Sunny", temperature: "Hot", humidity: "High", wind: "Strong", decision: "No"},
    ...>   %{outlook: "Overcast", temperature: "Hot", humidity: "High", wind: "Weak", decision: "Yes"},
    ...>   %{outlook: "Rain", temperature: "Mild", humidity: "High", wind: "Weak", decision: "Yes"},
    ...>   %{outlook: "Rain", temperature: "Cool", humidity: "Normal", wind: "Weak", decision: "Yes"},
    ...>   %{outlook: "Rain", temperature: "Cool", humidity: "Normal", wind: "Strong", decision: "No"},
    ...>   %{outlook: "Overcast", temperature: "Cool", humidity: "Normal", wind: "Strong", decision: "Yes"},
    ...>   %{outlook: "Sunny", temperature: "Mild", humidity: "High", wind: "Weak", decision: "No"},
    ...>   %{outlook: "Sunny", temperature: "Cool", humidity: "Normal", wind: "Weak", decision: "Yes"},
    ...>   %{outlook: "Rain", temperature: "Mild", humidity: "Normal", wind: "Weak", decision: "Yes"},
    ...>   %{outlook: "Sunny", temperature: "Mild", humidity: "Normal", wind: "Strong", decision: "Yes"},
    ...>   %{outlook: "Overcast", temperature: "Mild", humidity: "High", wind: "Strong", decision: "Yes"},
    ...>   %{outlook: "Overcast", temperature: "Hot", humidity: "Normal", wind: "Weak", decision: "Yes"},
    ...>   %{outlook: "Rain", temperature: "Mild", humidity: "High", wind: "Strong", decision: "No"}
    ...> ]
    ...>
    ...> f = DecisionTree.classifier(dataset, [:outlook, :temperature, :humidity, :wind], :decision)
    ...>
    ...> f.(%{outlook: "Sunny", temperature: "Mild", humidity: "Normal", wind: "Strong"})
    "Yes"

    ### Naive Bayes

    iex> alias Ml.NaiveBayes
    ...>
    ...> dataset = [
    ...>   %{risk: "high", collateral: "none", income: "low", debt: "high", credit_history: "bad"},
    ...>   %{risk: "high", collateral: "none", income: "moderate", debt: "high", credit_history: "unknown"},
    ...>   %{risk: "moderate", collateral: "none", income: "moderate", debt: "low", credit_history: "unknown"},
    ...>   %{risk: "high", collateral: "none", income: "low", debt: "low", credit_history: "unknown"},
    ...>   %{risk: "low", collateral: "none", income: "high", debt: "low", credit_history: "unknown"},
    ...>   %{risk: "low", collateral: "adequate", income: "high", debt: "low", credit_history: "unknown"},
    ...>   %{risk: "high", collateral: "none", income: "low", debt: "low", credit_history: "bad"},
    ...>   %{risk: "moderate", collateral: "adequate", income: "high", debt: "low", credit_history: "bad"},
    ...>   %{risk: "low", collateral: "none", income: "high", debt: "low", credit_history: "good"},
    ...>   %{risk: "low", collateral: "adequate", income: "high", debt: "high", credit_history: "good"},
    ...>   %{risk: "high", collateral: "none", income: "low", debt: "high", credit_history: "good"},
    ...>   %{risk: "moderate", collateral: "none", income: "moderate", debt: "high", credit_history: "good"},
    ...>   %{risk: "low", collateral: "none", income: "high", debt: "high", credit_history: "good"},
    ...>   %{risk: "high", collateral: "none", income: "moderate", debt: "high", credit_history: "bad"}
    ...> ]
    ...>
    ...> f = NaiveBayes.classifier(dataset, [:collateral, :income, :debt, :credit_history], :risk)
    ...>
    ...> f.(%{collateral: "none", income: "low", debt: "high", credit_history: "unknown"})
    "high"

  """
end
