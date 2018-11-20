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
    assert_receive {:y, 0.07562402677107753, _}
  end

  test "single input - double output" do
    temp_process = Utils.useless_process

    {:ok, pid} = start_link(1, 0.5, [self(), temp_process])

    refute_receive {:x, _, _}
    send pid, {:x, 0.05, self()}
    assert_receive {:x, 0.5071455518077935, _}

    refute_receive {:y, _, _}
    send pid, {:y, 0.7, self()}
    refute_receive {:y, _, _}
    send pid, {:y, 0.3, temp_process}
    assert_receive {:y, 0.11239971282658183, _}
  end

  test "triple input - single output" do
    temp_process_a = Utils.useless_process
    temp_process_b = Utils.useless_process

    {:ok, pid} = start_link(3, 0.001, [self()])

    refute_receive {:x, _, _}
    send pid, {:x, 0.5, self()}
    refute_receive {:x, _, _}
    send pid, {:x, 0.5, temp_process_a}
    refute_receive {:x, _, _}
    send pid, {:x, 0.5, temp_process_b}
    assert_receive {:x, 0.7328501094653352, _}

    refute_receive {:y, _, _}
    send pid, {:y, -0.9, self()}
    assert_receive {:y, 0.1720318341759958, _}

    refute_receive {:x, _, _}
    send pid, {:x, 0.5, self()}
    refute_receive {:x, _, _}
    send pid, {:x, 0.5, temp_process_a}
    refute_receive {:x, _, _}
    send pid, {:x, 0.5, temp_process_b}
    assert_receive {:x, 0.7328199336174254, _}

    refute_receive {:y, _, _}
    send pid, {:y, 0.9, self()}
    assert_receive {:y, 0.17201071898783696, _}

    refute_receive {:x, _, _}
    send pid, {:x, 0.5, self()}
    refute_receive {:x, _, _}
    send pid, {:x, 0.5, temp_process_a}
    refute_receive {:x, _, _}
    send pid, {:x, 0.5, temp_process_b}
    assert_receive {:x, 0.7327897556038121, _}
  end

end
