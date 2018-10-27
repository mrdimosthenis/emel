defmodule ClassificationTreeTest do
  use ExUnit.Case
  doctest Ml.ClassificationTree
  import Ml.ClassificationTree
  alias Help.Utils
  alias Help.DatasetManipulation

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
    age_categorizer = DatasetManipulation.categorizer(
      ["teen", 15, "young", 30, "middle age", 45, "old", 60, "very old"]
    )
    fare_categorizer = DatasetManipulation.categorizer(
      ["cheap", 10, "normal price", 100, "expensive"]
    )
    loneliness_categorizer = DatasetManipulation.categorizer(
      ["alone", 0.5, "Pair", 1.5, "accompanied"]
    )

    DatasetManipulation.load_dataset(
      path,
      ["PassengerId", "Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
    )
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
           {parsed_fare, ""} = Float.parse(fare)
           {parsed_parch, ""} = Integer.parse(parch)
           {parsed_sis_sp, ""} = Integer.parse(sis_sp)
           %{
             row |
             "Age" => age_categorizer.(parsed_age),
             "Fare" => fare_categorizer.(parsed_fare),
             "Parch" => loneliness_categorizer.(parsed_parch),
             "SibSp" => loneliness_categorizer.(parsed_sis_sp)
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
