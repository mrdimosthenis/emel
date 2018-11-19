defmodule Ml.Net.NeuronTest do
  use ExUnit.Case
  doctest Ml.ArtificialNeuron
  import Ml.Net.Neuron

  test "fire_ys" do
    {:ok, pid} = start_link(2, 0.5, [self()])
    refute_receive {:x, _, _}
    send pid, {:x, 0.05, :x1}
    refute_receive {:x, _, _}
    send pid, {:x, 0.15, :x2}
    assert_receive {:x, 0.5437845658942952, _}

    {:ok, pid} = start_link(3, 0.5, [self(), self()])
    refute_receive {:x, _, _}
    send pid, {:x, 0.95, :x1}
    refute_receive {:x, _, _}
    send pid, {:x, 0.85, :x2}
    refute_receive {:x, _, _}
    send pid, {:x, 0.95, :x3}
    assert_receive {:x, 0.8750889379213852, _}
  end

end
