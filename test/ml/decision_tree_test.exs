defmodule DecisionTreeTest do
  use ExUnit.Case
  doctest Ml.DecisionTree
  import Ml.DecisionTree
  alias Help.DatasetManipulation

  @observations [
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "o", windy: "f", golf: "y"},
    %{outlook: "o", windy: "f", golf: "y"},
    %{outlook: "o", windy: "t", golf: "y"},
    %{outlook: "o", windy: "t", golf: "y"},
    %{outlook: "r", windy: "f", golf: "y"},
    %{outlook: "r", windy: "t", golf: "y"},
    %{outlook: "s", windy: "t", golf: "n"},
    %{outlook: "s", windy: "t", golf: "n"},
    %{outlook: "r", windy: "f", golf: "n"},
    %{outlook: "r", windy: "f", golf: "n"},
    %{outlook: "r", windy: "t", golf: "n"}
  ]

  test "target attribute entropy" do
    assert entropy(@observations, :golf) == 0.9402859586706309
  end

  test "information gain" do
    assert information_gain(@observations, :golf, :outlook) == 0.2467498197744391
  end

  test "titanic" do
    train_dataset = DatasetManipulation.load_dataset(
      "resources/datasets/titanic/modified/train.csv",
      ["PassengerId", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Survived"]
    )
    test_dataset = DatasetManipulation.load_dataset(
      "resources/datasets/titanic/modified/test.csv",
      ["PassengerId", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
    )
    f = classifier(
      train_dataset,
      "Survived",
      ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
    )
    prediction_map = test_dataset
                     |> Enum.map(
                          fn %{"PassengerId" => passenger_id} = row ->
                            {passenger_id, f.(row)}
                          end
                        )
                     |> Map.new()
    result_map = DatasetManipulation.load_dataset(
                   "resources/datasets/titanic/modified/gender_submission.csv",
                   ["PassengerId", "Survived"]
                 )
                 |> Enum.map(
                      fn %{"PassengerId" => passenger_id, "Survived" => survived} ->
                        {passenger_id, survived}
                      end
                    )
                 |> Map.new()
    right_predictions = Enum.count(prediction_map, fn {k, v} -> v == result_map[k] end)
    success_rate = right_predictions / Enum.count(prediction_map)
    assert success_rate == 0.8308157099697885
  end

end
