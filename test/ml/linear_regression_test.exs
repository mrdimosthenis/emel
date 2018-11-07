defmodule Ml.LinearRegressionTest do
  use ExUnit.Case
  doctest Ml.LinearRegression
  import Ml.LinearRegression
  alias Help.DatasetManipulation

  test "linear-regression on two_times_minus_ten dataset" do
    {training_set, test_set} = "resources/datasets/two_times_minus_ten.csv"
                               |> DatasetManipulation.load_dataset()
                               |> Enum.map(
                                    fn %{"x" => x, "y" => y} ->
                                      %{"x" => DatasetManipulation.parse(x), "y" => DatasetManipulation.parse(y)}
                                    end
                                  )
                               |> DatasetManipulation.training_and_test_sets(0.8)
    f = predictor(training_set, ["x"], "y")
    predictions = Enum.map(test_set, fn row -> f.(row) end)
    actual_values = Enum.map(test_set, fn %{"y" => v} -> v end)
    error = DatasetManipulation.mean_absolute_error(predictions, actual_values)
    assert error == 1.1351826081695326
  end

end
