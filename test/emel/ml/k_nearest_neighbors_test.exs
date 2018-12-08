defmodule Emel.Ml.KNearestNeighborsTest do
  use ExUnit.Case
  doctest Emel.Ml.KNearestNeighbors
  import Emel.Ml.KNearestNeighbors
  alias Emel.Help.Model
  alias Emel.Help.ModelTest
  alias Emel.Math.Statistics
  alias Emel.Help.Io

  test "k-nearest-neighbors on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> Io.load_dataset()
                               |> Model.training_and_test_sets(0.75)
    {normalizes_training_set, _} = training_set
                                   |> Enum.map(&ModelTest.parse_flower/1)
                                   |> Model.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
    f = classifier(
      normalizes_training_set,
      ["petal_length", "petal_width", "sepal_length", "sepal_width"],
      "species",
      3
    )
    {normalizes_test_set, _} = test_set
                               |> Enum.map(&ModelTest.parse_flower/1)
                               |> Model.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
    predicted_classes = Enum.map(normalizes_test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.9473684210526315
  end

  test "k-nearest-neighbors on two_times_minus_ten dataset" do
    {training_set, test_set} = "resources/datasets/two_times_minus_ten.csv"
                               |> Io.load_dataset()
                               |> Enum.map(
                                    fn %{"x" => x, "y" => y} ->
                                      %{"x" => Model.parse(x), "y" => Model.parse(y)}
                                    end
                                  )
                               |> Model.training_and_test_sets(0.8)
    f = predictor(training_set, ["x"], "y", 3)
    predictions = Enum.map(test_set, fn row -> f.(row) end)
    actual_values = Enum.map(test_set, fn %{"y" => v} -> v end)
    error = Statistics.mean_absolute_error(predictions, actual_values)
    assert error == 1.3750000000000009
  end

end
