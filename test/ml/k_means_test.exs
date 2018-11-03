defmodule KMeansTest do
  use ExUnit.Case
  doctest Ml.KMeans
  import Ml.KMeans
  alias Help.DatasetManipulation

  def parse(flower) do
    flower
    |> Enum.map(
         fn {k, v} -> case Enum.member?(["petal_length", "petal_width", "sepal_length", "sepal_width"], k) do
                        true -> {k, DatasetManipulation.parse(v)}
                        false -> {k, v}
                      end
         end
       )
    |> Map.new()
  end

  def flower_to_point(%{"petal_length" => pl, "petal_width" => pw, "sepal_length" => sl, "sepal_width" => sw}) do
    [pl, pw, sl, sw]
  end

  test "k-means on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> DatasetManipulation.load_dataset()
                               |> DatasetManipulation.training_and_test_sets(0.80)
    f = training_set
        |> Enum.map(&parse/1)
        |> DatasetManipulation.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
        |> Enum.map(&flower_to_point/1)
        |> classifier(3)
    predicted_classes = test_set
                        |> Enum.map(&parse/1)
                        |> DatasetManipulation.normalize(["petal_length", "petal_width", "sepal_length", "sepal_width"])
                        |> Enum.map(&flower_to_point/1)
                        |> Enum.map(fn row -> f.(row) end)
    actual_classes = Enum.map(
      test_set,
      fn %{"species" => sp} ->
        case sp do
          "setosa" -> "0"
          "versicolor" -> "1"
          "virginica" -> "2"
        end
      end
    )
    score = DatasetManipulation.similarity(predicted_classes, actual_classes)
    assert score == 0.9666666666666667
  end

end
