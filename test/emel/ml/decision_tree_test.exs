defmodule DecisionTreeTest do
  use ExUnit.Case
  doctest Emel.Ml.DecisionTree
  import Emel.Ml.DecisionTree
  alias Emel.Help.Model
  alias Emel.Help.ModelTest
  alias Emel.Math.Statistics
  alias Emel.Help.Io

  test "decision tree on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> Io.load_dataset()
                               |> ModelTest.discrete_flower_attributes()
                               |> Model.training_and_test_sets(0.70)
    f = classifier(training_set, ["petal_length", "petal_width", "sepal_length", "sepal_width"], "species")
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.9555555555555556
  end

  test "decision tree on titanic dataset" do
    {training_set, test_set} = "resources/datasets/titanic.csv"
                               |> Io.load_dataset(
                                    ["Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
                                  )
                               |> Enum.filter(
                                    fn row ->
                                      row
                                      |> Map.values()
                                      |> Enum.all?(&(&1 != ""))
                                    end
                                  )
                               |> ModelTest.discrete_passenger_attributes()
                               |> Model.training_and_test_sets(0.90)
    f = classifier(training_set, ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"], "Survived")
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.7777777777777778
  end

end
