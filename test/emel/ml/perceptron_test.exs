defmodule Emel.Ml.PerceptronTest do
  use ExUnit.Case
  doctest Emel.Ml.Perceptron
  import Emel.Ml.Perceptron
  alias Emel.Help.Model
  alias Emel.Help.ModelTest
  alias Emel.Help.Io
  alias Emel.Math.Statistics
#  alias Emel.Help.Utils

  @dataset [
    %{a: 0, b: 0, and: false},
    %{a: 0, b: 1, and: false},
    %{a: 1, b: 0, and: false},
    %{a: 1, b: 1, and: true},
  ]

#  @xs Enum.map(@dataset, fn row -> [1 | Utils.map_vals(row, [:a, :b])] end)
#
#  test "updated_weights" do
#    assert updated_weights([0.0, 0.0, 0.0], [1, 0, 0], 0, 0.5) == [0.0, 0.0, 0.0]
#    assert updated_weights([0.0, 0.0, 0.0], [1, 0, 1], 0, 0.5) == [0.0, 0.0, 0.0]
#    assert updated_weights([0.0, 0.0, 0.0], [1, 1, 0], 0, 0.5) == [0.0, 0.0, 0.0]
#    assert updated_weights([0.0, 0.0, 0.0], [1, 1, 1], 1, 0.5) == [0.5, 0.5, 0.5]
#
#    assert updated_weights([0.5, 0.5, 0.5], [1, 0, 0], 0, 0.5) == [0.25, 0.5, 0.5]
#    assert updated_weights([0.25, 0.5, 0.5], [1, 0, 1], 0, 0.5) == [-0.125, 0.5, 0.125]
#    assert updated_weights([-0.125, 0.5, 0.125], [1, 1, 0], 0, 0.5) == [-0.3125, 0.3125, 0.125]
#    assert updated_weights([-0.3125, 0.3125, 0.125], [1, 1, 1], 1, 0.5) == [0.125, 0.75, 0.5625]
#
#    assert updated_weights([0.125, 0.75, 0.5625], [1, 0, 0], 0, 0.5) == [0.0625, 0.75, 0.5625]
#    assert updated_weights([0.0625, 0.75, 0.5625], [1, 0, 1], 0, 0.5) == [-0.25, 0.75, 0.25]
#    assert updated_weights([-0.25, 0.75, 0.25], [1, 1, 0], 0, 0.5) == [-0.5, 0.5, 0.25]
#    assert updated_weights([-0.5, 0.5, 0.25], [1, 1, 1], 1, 0.5) == [-0.125, 0.875, 0.625]
#  end
#
#  test "iterate" do
#    assert iterate([0, 0, 0], @xs, [0, 0, 0, 1], 0.5, 0.0000000001, 100) == [-0.5, 1.0, 0.75]
#
#    assert iterate([0, 0, 0], @xs, [0, 0, 0, 1], 0.5, 0.3750000000000001, 100000000000000000) ==
#             [-0.4999999999999998, 1.0, 0.7499999999999999]
#  end

  test "classifier" do
    f = classifier(@dataset, [:a, :b], :and)
    assert f.(%{a: 0, b: 0}) == false
    assert f.(%{a: 0, b: 1}) == false
    assert f.(%{a: 1, b: 0}) == false
    assert f.(%{a: 1, b: 1}) == true
  end

  test "perceptron on titanic dataset" do
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
    f = classifier(training_set, ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"], "Survived", 0.15, 0.05, 10)
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.8333333333333334
  end

end
