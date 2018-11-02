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
    shuffled = "resources/datasets/iris/original/iris.csv"
               |> DatasetManipulation.load_dataset()
               |> Enum.shuffle()
    num = length(shuffled)
    num_of_train = trunc(num * 0.7)
    train = shuffled
            |> Enum.take(num_of_train)
            |> Enum.map(&flower_to_point/1)
    f = classifier(train, 3)
    test = Enum.drop(shuffled, num_of_train)
    result_map = test
                 |> Enum.map(fn %{"species" => species} -> species end)
                 |> Enum.with_index()
                 |> Enum.map(
                      fn {sp, i} ->
                        {
                          i,
                          case sp do
                            "setosa" -> "0"
                            "versicolor" -> "1"
                            "virginica" -> "2"
                          end
                        }
                      end
                    )
                 |> Map.new()
    prediction_map = test
                     |> Enum.map(&flower_to_point/1)
                     |> Enum.map(fn point -> f.(point) end)
                     |> Enum.with_index()
                     |> Enum.map(fn {sp, i} -> {i, sp}end)
                     |> Map.new()
    right_predictions = Enum.count(prediction_map, fn {k, v} -> v == result_map[k] end)
    success_rate = right_predictions / Enum.count(prediction_map)
    assert success_rate == 0.8222222222222222
  end

end
