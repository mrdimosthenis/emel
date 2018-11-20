defmodule Ml.Net.NeuronTest do
  use ExUnit.Case
  doctest Ml.ArtificialNeuron
  import Ml.Net.Neuron
  alias Help.Utils

  test "double input - single output" do
    {:ok, pid} = start_link(2, 0.5, [self()])

    refute_receive {:x, _, _}
    send pid, {:x, 0.0, self()}
    refute_receive {:x, _, _}
    send pid, {:x, 0.0, Utils.useless_process}
    assert_receive {:x, 0.5, _}

    refute_receive {:y, _, _}
    send pid, {:y, 0.0, self()}
    assert_receive {:y, 0.21152913565577777, _}
  end

  test "single input - double output" do
    temp_process = Utils.useless_process

    {:ok, pid} = start_link(1, 0.5, [self(), temp_process])

    refute_receive {:x, _, _}
    send pid, {:x, 0.05, temp_process}
    assert_receive {:x, 0.5071455518077935, _}

#    refute_receive {:y, _, _}
#    send pid, {:y, 0.7, self()}
#    assert_receive {:y, 0.21152913565577777, _}

  end

  test "triple input - single output" do
    {:ok, pid} = start_link(3, 0.5, [self()])

    refute_receive {:x, _, _}
    send pid, {:x, 0.95, self()}
    refute_receive {:x, _, _}
    send pid, {:x, 0.85, Utils.useless_process}
    refute_receive {:x, _, _}
    send pid, {:x, 0.95, Utils.useless_process}
    assert_receive {:x, 0.8695904405699183, _}

  end

end
