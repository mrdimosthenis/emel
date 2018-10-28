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

  def parse_original_titanic_dataset(path) do
    age_categorizer = categorizer(
      ["teen", 15, "young", 30, "middle age", 45, "old", 60, "very old"]
    )
    fare_categorizer = categorizer(
      ["cheap", 10, "normal price", 100, "expensive"]
    )
    loneliness_categorizer = categorizer(
      ["alone", 0.5, "Pair", 1.5, "accompanied"]
    )

    path
    |> load_dataset(["PassengerId", "Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"])
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

  test "titanic" do
    original_train_path = "resources/datasets/titanic/original/train.csv"
    original_test_path = "resources/datasets/titanic/original/test.csv"
    modified_train_path = "resources/datasets/titanic/modified/train.csv"
    modified_test_path = "resources/datasets/titanic/modified/test.csv"
    columns_of_interest = ["PassengerId", "Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
    assert parse_original_titanic_dataset(original_train_path) == load_dataset(modified_train_path, columns_of_interest)
    assert parse_original_titanic_dataset(original_test_path) == load_dataset(modified_test_path, columns_of_interest)
  end

  def parse_original_iris_dataset(path) do
    sepal_length_categorizer = categorizer(
      ["very small", 4.9, "small", 5.8, "large", 7, "very large"]
    )
    sepal_width_categorizer = categorizer(
      ["very small", 2.3, "small", 3.4, "large", 3.8, "very large"]
    )
    petal_length_categorizer = categorizer(
      ["very small", 1.9, "small", 3, "normal", 4.5, "large", 5.1, "very large"]
    )
    petal_width_categorizer = categorizer(
      ["very small", 0.6, "small", 1, "normal", 1.4, "large", 1.8, "very large"]
    )

    path
    |> load_dataset(["sepal_length", "sepal_width", "petal_length", "petal_width", "species"])
    |> Enum.map(
         fn %{
              "sepal_length" => sepal_length,
              "sepal_width" => sepal_width,
              "petal_length" => petal_length,
              "petal_width" => petal_width
            } = row ->
           {parsed_sepal_length, ""} = Float.parse(sepal_length)
           {parsed_sepal_width, ""} = Float.parse(sepal_width)
           {parsed_petal_length, ""} = Float.parse(petal_length)
           {parsed_petal_width, ""} = Float.parse(petal_width)
           %{
             row |
             "sepal_length" => sepal_length_categorizer.(parsed_sepal_length),
             "sepal_width" => sepal_width_categorizer.(parsed_sepal_width),
             "petal_length" => petal_length_categorizer.(parsed_petal_length),
             "petal_width" => petal_width_categorizer.(parsed_petal_width)
           }

         end
       )
  end

  test "iris" do
    original_iris_dataset = parse_original_iris_dataset("resources/datasets/iris/original/iris.csv")
    shuffled = Enum.shuffle(original_iris_dataset)
    num = length(shuffled)
    num_of_train = trunc(num * 0.7)
    train = Enum.take(shuffled, num_of_train)
    test_base = shuffled
                |> Enum.drop(num_of_train)
                |> Enum.with_index()
                |> Enum.map(fn {row, index} -> Map.merge(row, %{"id" => Integer.to_string(index)}) end)
    test = Enum.map(test_base, fn row -> Map.drop(row, ["species"]) end)
    results = Enum.map(
      test_base,
      fn row -> Map.drop(row, ["sepal_length", "sepal_width", "petal_length", "petal_width"]) end
    )
    assert train == load_dataset("resources/datasets/iris/modified/train.csv")
    assert test == load_dataset("resources/datasets/iris/modified/test.csv")
    assert results == load_dataset("resources/datasets/iris/modified/results.csv")
  end

end
