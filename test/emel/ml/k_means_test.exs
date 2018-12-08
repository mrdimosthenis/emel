defmodule KMeansTest do
  use ExUnit.Case
  doctest Emel.Ml.KMeans
  import Emel.Ml.KMeans
  alias Emel.Help.Model
  alias Emel.Help.ModelTest
  alias Emel.Math.Statistics
  alias Emel.Help.Io

  test "k-means on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> Io.load_dataset()
                               |> Model.training_and_test_sets(0.80)
    {normalizes_training_set, _} = training_set
                                   |> Enum.map(&ModelTest.parse_flower/1)
                                   |> Model.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
    f = classifier(
      normalizes_training_set,
      ["petal_length", "petal_width", "sepal_length", "sepal_width"],
      ["setosa", "versicolor", "virginica"]
    )
    {normalizes_test_set, _} = test_set
                               |> Enum.map(&ModelTest.parse_flower/1)
                               |> Model.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
    predicted_classes = Enum.map(normalizes_test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.9666666666666667
  end

end
