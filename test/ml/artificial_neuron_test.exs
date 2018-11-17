defmodule ArtificialNeuronTest do
  use ExUnit.Case
  doctest Ml.ArtificialNeuron
  import Ml.ArtificialNeuron
  alias Ml.ArtificialNeuron.Neuron
  alias Help.Model
  alias Help.ModelTest
  alias Help.Io
  alias Math.Statistics

  test "neuron_output" do
    neuron = Neuron.new([0.3, 0.5, 0.9])
    x = [0.73, 0.79, 0.69]
    assert neuron_output(neuron, x) == 0.7746924929149283
  end

  test "update_neuron_weights" do
    neuron = Neuron.new([0.3, 0.5, 0.9])

    assert update_neuron_weights(neuron, 0, 0.5, 1).ws == [0.2625, 0.4375, 0.7875]
    assert update_neuron_weights(neuron, 1, 0.5, 1).ws == [0.33749999999999997, 0.5625, 1.0125]
    assert update_neuron_weights(neuron, 0.5, 0.5, 1).ws == [0.3, 0.5, 0.9]

    assert update_neuron_weights(neuron, 0, 0.5, 0.3).ws == [0.28875, 0.48125, 0.8662500000000001]
    assert update_neuron_weights(neuron, 1, 0.5, 0.3).ws == [0.31125, 0.51875, 0.9337500000000001]
    assert update_neuron_weights(neuron, 0.5, 0.5, 0.3).ws == [0.3, 0.5, 0.9]
  end

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
    f = classifier(training_set, ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"], "Survived",
                                           {
                                           &Calculus.logistic_function/1,
                                           &Calculus.logistic_derivative/1,
                                           &Calculus.logistic_inverse/1
                                            }, 0.001, 0.01, 10)
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.8194444444444444
  end

end
