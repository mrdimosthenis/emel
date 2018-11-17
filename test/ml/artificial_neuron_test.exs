defmodule ArtificialNeuronTest do
  use ExUnit.Case
  doctest Ml.ArtificialNeuron
  import Ml.ArtificialNeuron
  alias Help.Model
  alias Help.ModelTest
  alias Help.Io
  alias Math.Statistics

  test "artificial neuron on titanic dataset" do
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
                                          "0" -> false
                                          "1" -> true
                                        end,
                                        "Sex" => case sex do
                                          "male" -> 1
                                          "female" -> 0
                                        end
                                      }
                                    end
                                  )
                               |> Model.training_and_test_sets(0.90)
    f = classifier(training_set, ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"], "Survived", 0.5, 0.0001, 10)
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.8194444444444444
  end

end
