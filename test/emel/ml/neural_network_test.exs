defmodule Emel.Ml.NeuralNetworkTest do
  use ExUnit.Case
  import Emel.Ml.NeuralNetwork
  alias Emel.Help.Model
  alias Emel.Help.ModelTest
  alias Emel.Help.Io
  alias Emel.Math.Statistics

  test "neural network on titanic dataset" do
    {normalized_dataset, _} = "resources/datasets/titanic.csv"
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
    {training_set, test_set} = normalized_dataset
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
                               |> Model.training_and_test_sets(0.60)
    f = classifier(
      training_set,
      ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"],
      "Survived",
      [7, 3],
      0.5,
      0.1,
      10
    )
    predicted_classes = f.(test_set)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    _score = Statistics.similarity(predicted_classes, actual_classes)
  end

end
