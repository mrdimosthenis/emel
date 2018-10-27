defmodule Help.DatasetManipulationTest do
  @moduledoc false
  use ExUnit.Case
  doctest Help.DatasetManipulation
  alias Help.DatasetManipulation

  test "category" do
    f1 = DatasetManipulation.categorizer([:negative, 0, :non_negative])
    assert f1.(-3) == :negative
    assert f1.(1) == :non_negative

    f2 = DatasetManipulation.categorizer(["very small", 3, "small", 7, "moderate", 12, "large"])
    assert f2.(1) == "very small"
    assert f2.(6) == "small"
    assert f2.(10) == "moderate"
    assert f2.(100) == "large"

    assert_raise RuntimeError, "Categories are not separated by valid thresholds", fn ->
      _ = DatasetManipulation.categorizer([:negative, 0, :non_negative, -1, :whatever])
    end

    assert_raise RuntimeError, "Categories are not separated by valid thresholds", fn ->
      _ = DatasetManipulation.categorizer([:negative, :whatever])
    end
  end

end
