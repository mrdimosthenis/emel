defmodule Ml.KNearestNeighborsTest do
  use ExUnit.Case
  doctest Ml.KNearestNeighbors
  import Ml.KNearestNeighbors
  alias Help.Model
  alias Help.ModelTest
  alias Math.Statistics
  alias Help.Io

  test "k-nearest-neighbors on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> Io.load_dataset()
                               |> Model.training_and_test_sets(0.75)
    f = training_set
        |> Enum.map(&ModelTest.parse_flower/1)
        |> Model.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
        |> classifier(
             ["petal_length", "petal_width", "sepal_length", "sepal_width"],
             "species",
             3
           )
    predicted_classes = test_set
                        |> Enum.map(&ModelTest.parse_flower/1)
                        |> Model.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
                        |> Enum.map(fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.9736842105263158
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
    assert error == 1.7500000000000007
  end

end
