defmodule ClassificationTreeTest do
  use ExUnit.Case
  doctest Ml.ClassificationTree
  import Ml.ClassificationTree
  alias Help.Utils

  @a [
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
    assert entropy(@a, :golf) == 0.9402859586706309
  end

  test "information gain" do
    assert information_gain(@a, :golf, :outlook) == 0.2467498197744391
  end

  def parse_dataset(path) do
    path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.map(fn row -> Map.drop(row, ["Cabin", "Embarked", "Name", "Ticket"]) end)
    |> Stream.filter(
         fn row ->
           row
           |> Map.values()
           |> Enum.all?(&(&1 != ""))
         end
       )
    |> Enum.map(
         fn %{"Age" => age, "Fare" => fare, "Parch" => parch, "SibSp" => sis_sp} = row ->
           {parsed_age, ""} = Float.parse(age)
           age_category = cond do
             parsed_age < 15 -> "teen"
             parsed_age < 30 -> "young"
             parsed_age < 45 -> "middle age"
             parsed_age < 60 -> "old"
             true -> "very old"
           end
           {parsed_fare, ""} = Float.parse(fare)
           fare_category = cond do
             parsed_fare < 10 -> "cheap"
             parsed_fare < 100 -> "normal price"
             true -> "expensive"
           end
           {parsed_parch, ""} = Integer.parse(parch)
           parch_category = cond do
             parsed_parch == 0 -> "alone"
             parsed_parch == 1 -> "pair"
             true -> "accompanied"
           end
           {parsed_sis_sp, ""} = Integer.parse(sis_sp)
           sis_sp_category = cond do
             parsed_sis_sp == 0 -> "alone"
             parsed_sis_sp == 1 -> "pair"
             true -> "accompanied"
           end
           %{
             row |
             "Age" => age_category,
             "Fare" => fare_category,
             "Parch" => parch_category,
             "SibSp" => sis_sp_category
           }
         end
       )
  end

  test "titanic dataset" do
    train = parse_dataset("resources/datasets/titanic/train.csv")
    f = classifier(train, "Survived", ["Age", "Fare", "Parch", "Pclass", "Sex", "SibSp"])
    predictions = "resources/datasets/titanic/test.csv"
                  |> parse_dataset()
                  |> Enum.map(
                       fn %{"PassengerId" => passenger_id} = row ->
                         %Utils.Pair{first: passenger_id, second: f.(row)}
                       end
                     )
                  |> Enum.filter(&(&1.second))
                  |> Enum.map(&({&1.first, &1.second}))
                  |> Map.new()
    results = "resources/datasets/titanic/gender_submission.csv"
              |> File.stream!()
              |> CSV.decode!(headers: true)
              |> Enum.map(
                   fn %{"PassengerId" => passenger_id, "Survived" => survived} ->
                     {passenger_id, survived}
                   end
                 )
              |> Map.new()
    right_predictions = Enum.count(predictions, fn {k, v} -> v == results[k] end)
    success_rate = right_predictions / Enum.count(predictions)
    assert success_rate > 0.8
  end

end
