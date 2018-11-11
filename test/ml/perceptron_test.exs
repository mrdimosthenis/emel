defmodule Ml.PerceptronTest do
  use ExUnit.Case
  doctest Ml.Perceptron
  import Ml.Perceptron

  test "weights_updated" do
    assert weights_updated([0.0, 0.0, 0.0], [1, 0, 0], 0, 0.5) == [0.0, 0.0, 0.0]
    assert weights_updated([0.0, 0.0, 0.0], [1, 0, 1], 0, 0.5) == [0.0, 0.0, 0.0]
    assert weights_updated([0.0, 0.0, 0.0], [1, 1, 0], 0, 0.5) == [0.0, 0.0, 0.0]
    assert weights_updated([0.0, 0.0, 0.0], [1, 1, 1], 1, 0.5) == [0.5, 0.5, 0.5]

    assert weights_updated([0.5, 0.5, 0.5], [1, 0, 0], 0, 0.5) == [0.25, 0.5, 0.5]
    assert weights_updated([0.25, 0.5, 0.5], [1, 0, 1], 0, 0.5) == [-0.125, 0.5, 0.125]
    assert weights_updated([-0.125, 0.5, 0.125], [1, 1, 0], 0, 0.5) == [-0.3125, 0.3125, 0.125]
    assert weights_updated([-0.3125, 0.3125, 0.125], [1, 1, 1], 1, 0.5) == [0.125, 0.75, 0.5625]

    assert weights_updated([0.125, 0.75, 0.5625], [1, 0, 0], 0, 0.5) == [0.0625, 0.75, 0.5625]
    assert weights_updated([0.0625, 0.75, 0.5625], [1, 0, 1], 0, 0.5) == [-0.25, 0.75, 0.25]
    assert weights_updated([-0.25, 0.75, 0.25], [1, 1, 0], 0, 0.5) == [-0.5, 0.5, 0.25]
    assert weights_updated([-0.5, 0.5, 0.25], [1, 1, 1], 1, 0.5) == [-0.125, 0.875, 0.625]

    assert weights_updated(
             [0.0, 0.0, 0.0],
             [
               [1, 0, 0],
               [1, 0, 1],
               [1, 1, 0],
               [1, 1, 1]
             ],
             [0, 0, 0, 1],
             0.5
           ) == [0.5, 0.5, 0.5]

    assert weights_updated(
             [0.5, 0.5, 0.5],
             [
               [1, 0, 0],
               [1, 0, 1],
               [1, 1, 0],
               [1, 1, 1]
             ],
             [0, 0, 0, 1],
             0.5
           ) == [0.125, 0.75, 0.5625]

    assert weights_updated(
             [0.125, 0.75, 0.5625],
             [
               [1, 0, 0],
               [1, 0, 1],
               [1, 1, 0],
               [1, 1, 1]
             ],
             [0, 0, 0, 1],
             0.5
           ) == [-0.125, 0.875, 0.625]
  end

end
