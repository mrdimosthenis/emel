defmodule ArtificialNeuronTest do
  use ExUnit.Case
  doctest Ml.ArtificialNeuron
  import Ml.ArtificialNeuron
  alias Ml.ArtificialNeuron.Neuron

  test "neuron_output" do
    neuron = Neuron.new([0.3, 0.5, 0.9])
    xs = [0.73, 0.79, 0.69]
    assert neuron_output(xs, neuron) == 0.7746924929149283
  end
  
end
