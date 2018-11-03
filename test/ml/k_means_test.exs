defmodule KMeansTest do
  use ExUnit.Case
  doctest Ml.KMeans
  import Ml.KMeans
  alias Help.DatasetManipulation

  def flower_to_point(%{"petal_length" => pl, "petal_width" => pw, "sepal_length" => sl, "sepal_width" => sw}) do
    {parsed_petal_length, ""} = Float.parse(pl)
    {parsed_petal_width, ""} = Float.parse(pw)
    {parsed_sepal_length, ""} = Float.parse(sl)
    {parsed_sepal_width, ""} = Float.parse(sw)
    [parsed_sepal_length, parsed_sepal_width, parsed_petal_length, parsed_petal_width]
  end

  test "iris" do
    {training_set, test_set} = "resources/datasets/iris/original/iris.csv"
                               |> DatasetManipulation.load_dataset()
                               |> DatasetManipulation.training_and_test_sets(0.7)
    f = training_set
        |> Enum.map(&flower_to_point/1)
        |> classifier(3)
    predicted_classes = test_set
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
    assert score == 0.8222222222222222
  end

end
