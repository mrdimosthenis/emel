defmodule Emel.Ml.NaiveBayesTest do
  use ExUnit.Case
  doctest Emel.Ml.NaiveBayes
  import Emel.Ml.NaiveBayes
  alias Emel.Help.Model
  alias Emel.Help.ModelTest
  alias Emel.Math.Statistics
  alias Emel.Help.Io

  @observations [
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Fast", weather: "Sunny"},
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Fast", weather: "Sunny"},
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Slow", weather: "Sunny"},
    %{humidity: "Not Humid", temperature: "Cold", wind_speed: "Fast", weather: "Sunny"},
    %{humidity: "Not Humid", temperature: "Hot", wind_speed: "Slow", weather: "Rainy"},
    %{humidity: "Not Humid", temperature: "Cold", wind_speed: "Fast", weather: "Rainy"},
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Slow", weather: "Rainy"},
    %{humidity: "Humid", temperature: "Cold", wind_speed: "Slow", weather: "Rainy"}
  ]

  test "prior probability" do
    assert prior_probability(@observations, :temperature, "Hot") == 5 / 8
    assert prior_probability(@observations, :wind_speed, "Slow") == 4 / 8

    assert prior_probability(@observations, :weather, "Sunny") == 0.5
    assert prior_probability(@observations, :weather, "Rainy") == 0.5
  end

  test "probability B given A" do
    assert probability_B_given_A(@observations, :temperature, "Hot", :wind_speed, "Slow") == 3 / 4
    assert probability_B_given_A(@observations, :wind_speed, "Slow", :temperature, "Hot") == 3 / 5

    assert probability_B_given_A(@observations, :humidity, "Humid", :weather, "Sunny") == 0.75
    assert probability_B_given_A(@observations, :temperature, "Cold", :weather, "Sunny") == 0.25
    assert probability_B_given_A(@observations, :wind_speed, "Fast", :weather, "Sunny") == 0.75

    assert probability_B_given_A(@observations, :humidity, "Humid", :weather, "Rainy") == 0.5
    assert probability_B_given_A(@observations, :temperature, "Cold", :weather, "Rainy") == 0.5
    assert probability_B_given_A(@observations, :wind_speed, "Fast", :weather, "Rainy") == 0.25

  end

  test "combined posteriori probability" do
    assert combined_posterior_probability(
             @observations,
             %{humidity: "Humid", temperature: "Cold", wind_speed: "Fast"},
             :weather,
             "Sunny"
           ) == 0.0703125
    assert combined_posterior_probability(
             @observations,
             %{humidity: "Humid", temperature: "Cold", wind_speed: "Fast"},
             :weather,
             "Rainy"
           ) == 0.03125
  end

  test "classifier" do
    f = classifier(@observations, [:humidity, :temperature, :wind_speed], :weather)
    assert f.(%{humidity: "Humid", temperature: "Cold", wind_speed: "Fast"}) == "Sunny"
  end

  test "naive Bayes on iris dataset" do
    {training_set, test_set} = "resources/datasets/iris.csv"
                               |> Io.load_dataset()
                               |> ModelTest.discrete_flower_attributes()
                               |> Model.training_and_test_sets(0.7)
    f = classifier(training_set, ["petal_length", "petal_width", "sepal_length", "sepal_width"], "species")
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"species" => sp} -> sp end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.9333333333333333
  end

  test "naive Bayes on titanic dataset" do
    {training_set, test_set} = "resources/datasets/titanic.csv"
                               |> Io.load_dataset(
                                    ["Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
                                  )
                               |> Enum.filter(
                                    fn row ->
                                      row
                                      |> Map.values()
                                      |> Enum.all?(&(&1 != ""))
                                    end
                                  )
                               |> ModelTest.discrete_passenger_attributes()
                               |> Model.training_and_test_sets(0.8)
    f = classifier(training_set, ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"], "Survived")
    predicted_classes = Enum.map(test_set, fn row -> f.(row) end)
    actual_classes = Enum.map(test_set, fn %{"Survived" => sv} -> sv end)
    score = Statistics.similarity(predicted_classes, actual_classes)
    assert score == 0.7412587412587412
  end

end
