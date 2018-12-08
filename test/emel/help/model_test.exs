defmodule Emel.Help.ModelTest do
  use ExUnit.Case
  doctest Emel.Help.Model
  import Emel.Help.Model
  alias Emel.Help.Utils

  def parse_flower(flower) do
    Utils.update_map(
      flower,
      ["petal_length", "petal_width", "sepal_length", "sepal_width"],
      fn v -> parse(v) end
    )
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

  def continuous_passenger_attributes(passengers) do
    Enum.map(
      passengers,
      fn m ->
        Utils.update_map(
          m,
          ["Pclass", "Age", "Fare", "Parch", "SibSp"],
          fn v -> parse(v) end
        )
      end
    )
  end

end
