defmodule Ml.KNearestNeighborsTest do
  use ExUnit.Case
  doctest Ml.KNearestNeighbors
  import Ml.KNearestNeighbors
  alias Help.DatasetManipulation
  alias Help.DatasetManipulationTest

  test "k-nearest-neighbors on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> DatasetManipulation.load_dataset()
                               |> DatasetManipulation.training_and_test_sets(0.75)
    f = training_set
        |> Enum.map(&DatasetManipulationTest.parse_flower/1)
        |> DatasetManipulation.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
        |> classifier(
             ["petal_length", "petal_width", "sepal_length", "sepal_width"],
             "species",
             3
           )
    predicted_classes = test_set
                        |> Enum.map(&DatasetManipulationTest.parse_flower/1)
                        |> DatasetManipulation.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
                        |> Enum.map(fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = DatasetManipulation.accuracy(predicted_classes, actual_classes)
    assert score == 0.9736842105263158
  end

end
