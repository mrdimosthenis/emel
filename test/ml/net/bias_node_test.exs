defmodule Ml.Net.BiasNodeTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.BiasNode
  alias Ml.Net.BiasNode
  alias Help.Utils

  test "bias node" do
    other_neuron = Utils.useless_process()

    {:ok, pid} = GenServer.start_link(BiasNode, [other_neuron, self()])

    assert_receive {:fire, _, 1.0}
    refute_receive {:fire, _, _}
    send(pid, {:back_propagate, self(), 0.1})
    assert_receive {:fire, _, 1.0}
    refute_receive {:fire, _, _}
    send(pid, {:back_propagate, other_neuron, 0.2})
    refute_receive {:fire, _, _}
    send(pid, {:back_propagate, self(), 0.1})
    assert_receive {:fire, _, 1.0}
  end

end
