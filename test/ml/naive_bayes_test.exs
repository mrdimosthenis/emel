defmodule Ml.NaiveBayesTest do
  use ExUnit.Case
  doctest Ml.NaiveBayes
  import Ml.NaiveBayes

  @observations [
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Fast", weather: "Sunny"},
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Fast", weather: "Sunny"},
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Slow", weather: "Sunny"},
    %{humidity: "Not", temperature: "Humid", wind_speed: "Cold", weather: "Fast	Sunny"},
    %{humidity: "Not", temperature: "Humid", wind_speed: "Hot", weather: "Slow	Rainy"},
    %{humidity: "Not", temperature: "Humid", wind_speed: "Cold", weather: "Fast	Rainy"},
    %{humidity: "Humid", temperature: "Hot", wind_speed: "Slow", weather: "Rainy"},
    %{humidity: "Humid", temperature: "Cold", wind_speed: "Slow", weather: "Rainy"}
  ]

  test "prior probability" do
    assert prior_probability(@observations, :temperature, "Hot") == 1 / 2
    assert prior_probability(@observations, :wind_speed, "Slow") == 3 / 8
  end

  test "probability B given A" do
    assert probability_B_given_A(@observations, :temperature, "Hot", :wind_speed, "Slow") == 2 / 3
    assert probability_B_given_A(@observations, :wind_speed, "Slow", :temperature, "Hot") == 2 / 4
  end

end
