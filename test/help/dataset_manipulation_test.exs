defmodule Help.DatasetManipulationTest do
  @moduledoc false
  use ExUnit.Case
  doctest Help.DatasetManipulation
  import Help.DatasetManipulation

  def parse_flower(flower) do
    flower
    |> Enum.map(
         fn {k, v} -> case Enum.member?(["petal_length", "petal_width", "sepal_length", "sepal_width"], k) do
                        true -> {k, parse(v)}
                        false -> {k, v}
                      end
         end
       )
    |> Map.new()
  end

  def discrete_flower_attributes(flowers) do
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
    Enum.map(
      flowers,
      fn %{
           "sepal_length" => sl,
           "sepal_width" => sw,
           "petal_length" => pl,
           "petal_width" => pw
         } = row ->
        %{
          row |
          "sepal_length" => sepal_length_categorizer.(parse(sl)),
          "sepal_width" => sepal_width_categorizer.(parse(sw)),
          "petal_length" => petal_length_categorizer.(parse(pl)),
          "petal_width" => petal_width_categorizer.(parse(pw)),
        }
      end
    )
  end

  def discrete_passenger_attributes(passengers) do
    age_categorizer = categorizer(
      ["teen", 15, "young", 30, "middle age", 45, "old", 60, "very old"]
    )
    fare_categorizer = categorizer(
      ["cheap", 10, "normal price", 100, "expensive"]
    )
    loneliness_categorizer = categorizer(
      ["alone", 0.5, "Pair", 1.5, "accompanied"]
    )
    Enum.map(
      passengers,
      fn %{"Age" => age, "Fare" => fare, "Parch" => parch, "SibSp" => sis_sp} = row ->
        %{
          row |
          "Age" => age_categorizer.(parse(age)),
          "Fare" => fare_categorizer.(parse(fare)),
          "Parch" => loneliness_categorizer.(parse(parch)),
          "SibSp" => loneliness_categorizer.(parse(sis_sp))
        }
      end
    )
  end

  test "categorizer" do
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

  test "normalize" do
    assert normalize([%{a: 0}, %{a: 1}], [:a]) == [%{a: 0}, %{a: 1}]
    assert normalize([%{"x" => 1}, %{"x" => 2}, %{"x" => 1.5}], ["x"]) ==
             [%{"x" => 0}, %{"x" => 1}, %{"x" => 0.5}]
    assert normalize([%{"x" => 1, "y" => -2, "z" => -4}, %{"x" => 2, "y" => 2, "z" => -8}], ["y", "z"]) ==
             [%{"x" => 1, "y" => 0, "z" => 1}, %{"x" => 2, "y" => 1, "z" => 0}]
  end

end
