defmodule Ml.NaiveBayesTest do
  use ExUnit.Case
  doctest Ml.NaiveBayes
  import Ml.NaiveBayes
  alias Help.DatasetManipulation

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
    f = classifier(@observations, :weather, [:humidity, :temperature, :wind_speed])
    assert f.(%{humidity: "Humid", temperature: "Cold", wind_speed: "Fast"}) == "Sunny"
  end

end
