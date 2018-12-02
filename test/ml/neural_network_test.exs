defmodule Ml.NeuralNetworkTest do
  use ExUnit.Case
  doctest Ml.NeuralNetwork
  import Ml.NeuralNetwork
  alias Help.Model
  alias Help.ModelTest
  alias Help.Io
  alias Math.Statistics

  test "neural network on titanic dataset" do
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
                               |> ModelTest.continuous_passenger_attributes()
                               |> Model.normalize(["Pclass", "Age", "SibSp", "Parch", "Fare"])
                               |> Enum.map(
                                    fn %{"Survived" => survived, "Sex" => sex} = row ->
                                      %{
                                        row |
                                        "Survived" => case survived do
                                          "0" -> "Survived"
                                          "1" -> "Died"
                                        end,
                                        "Sex" => case sex do
                                          "male" -> 1
                                          "female" -> 0
                                        end
                                      }
                                    end
                                  )
                               |> Model.training_and_test_sets(0.90)
    f = classifier(
      training_set,
      ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"],
      "Survived",
      [7, 5, 3],
      0.01,
      0.001,
      10
    )
    predicted_classes = f.(test_set)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score > 0.7
  end

end
