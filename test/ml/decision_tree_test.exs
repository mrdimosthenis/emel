defmodule DecisionTreeTest do
  use ExUnit.Case
  doctest Ml.DecisionTree
  import Ml.DecisionTree
  alias Help.DatasetManipulation
  alias Help.DatasetManipulationTest

  @observations [
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "o", windy: "f", golf: "y"},
    %{outlook: "o", windy: "f", golf: "y"},
    %{outlook: "o", windy: "t", golf: "y"},
    %{outlook: "o", windy: "t", golf: "y"},
    %{outlook: "r", windy: "f", golf: "y"},
    %{outlook: "r", windy: "t", golf: "y"},
    %{outlook: "s", windy: "t", golf: "n"},
    %{outlook: "s", windy: "t", golf: "n"},
    %{outlook: "r", windy: "f", golf: "n"},
    %{outlook: "r", windy: "f", golf: "n"},
    %{outlook: "r", windy: "t", golf: "n"}
  ]

  test "target attribute entropy" do
    assert entropy(@observations, :golf) == 0.9402859586706309
  end

  test "information gain" do
    assert information_gain(@observations, :golf, :outlook) == 0.2467498197744391
  end

  test "decision tree on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> DatasetManipulation.load_dataset()
                               |> DatasetManipulationTest.discrete_flower_attributes()
                               |> DatasetManipulation.training_and_test_sets(0.70)
    f = classifier(training_set, ["petal_length", "petal_width", "sepal_length", "sepal_width"], "species")
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = DatasetManipulation.similarity(predicted_classes, actual_classes)
    assert score == 0.9555555555555556
  end

  test "decision tree on titanic dataset" do
    {training_set, test_set} = "resources/datasets/titanic.csv"
                               |> DatasetManipulation.load_dataset(
                                    ["Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
                                  )
                               |> Enum.filter(
                                    fn row ->
                                      row
                                      |> Map.values()
                                      |> Enum.all?(&(&1 != ""))
                                    end
                                  )
                               |> DatasetManipulationTest.discrete_passenger_attributes()
                               |> DatasetManipulation.training_and_test_sets(0.90)
    f = classifier(training_set, ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"], "Survived")
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = DatasetManipulation.similarity(predicted_classes, actual_classes)
    assert score == 0.7777777777777778
  end

end
