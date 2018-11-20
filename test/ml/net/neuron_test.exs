defmodule Ml.Net.NeuronTest do
  use ExUnit.Case
  doctest Ml.ArtificialNeuron
  import Ml.Net.Neuron

  test "double input - single output" do
    {:ok, pid} = start_link(2, 0.5, [self()])
    refute_receive {:x, _, _}
    send pid, {:x, 0.0, :x1}
    refute_receive {:x, _, _}
    send pid, {:x, 0.0, :x2}
    assert_receive {:x, 0.5, _}
  end

  test "single input - double output" do
    {:ok, pid} = start_link(1, 0.5, [self(), self()])
    refute_receive {:x, _, _}
    send pid, {:x, 0.05, :x1}
    assert_receive {:x, 0.5071455518077935, _}
  end

  test "triple input - single output" do
    {:ok, pid} = start_link(3, 0.5, [self()])
    refute_receive {:x, _, _}
    send pid, {:x, 0.95, :x1}
    refute_receive {:x, _, _}
    send pid, {:x, 0.85, :x2}
    refute_receive {:x, _, _}
    send pid, {:x, 0.95, :x3}
    assert_receive {:x, 0.8695904405699183, _}
  end

end
