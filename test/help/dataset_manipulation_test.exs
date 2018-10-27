defmodule Help.DatasetManipulationTest do
  @moduledoc false
  use ExUnit.Case
  doctest Help.DatasetManipulation
  import Help.DatasetManipulation

  test "category" do
    f1 = categorizer([:negative, 0, :non_negative])
    assert f1.(-3) == :negative
    assert f1.(1) == :non_negative

    f2 = categorizer(["very small", 3, "small", 7, "moderate", 12, "large"])
    assert f2.(1) == "very small"
    assert f2.(6) == "small"
    assert f2.(10) == "moderate"
    assert f2.(100) == "large"

    assert_raise RuntimeError, "Categories are not separated by valid thresholds", fn ->
      _ = categorizer([:negative, 0, :non_negative, -1, :whatever])
    end

    assert_raise RuntimeError, "Categories are not separated by valid thresholds", fn ->
      _ = categorizer([:negative, :whatever])
    end
  end

  def parse_original_dataset(path) do
    age_categorizer = categorizer(
      ["teen", 15, "young", 30, "middle age", 45, "old", 60, "very old"]
    )
    fare_categorizer = categorizer(
      ["cheap", 10, "normal price", 100, "expensive"]
    )
    loneliness_categorizer = categorizer(
      ["alone", 0.5, "Pair", 1.5, "accompanied"]
    )

    load_dataset(path, ["PassengerId", "Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"])
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

  test "load dataset" do
    original_train_path = "resources/datasets/titanic/original/train.csv"
    original_test_path = "resources/datasets/titanic/original/test.csv"
    modified_train_path = "resources/datasets/titanic/modified/train.csv"
    modified_test_path = "resources/datasets/titanic/modified/test.csv"
    columns_of_interest = ["PassengerId", "Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
    assert parse_original_dataset(original_train_path) == load_dataset(modified_train_path, columns_of_interest)
    assert parse_original_dataset(original_test_path) == load_dataset(modified_test_path, columns_of_interest)
  end

end
