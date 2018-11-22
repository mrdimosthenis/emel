defmodule Ml.Net.InputNodeTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.InputNode
  alias Ml.Net.InputNode
  alias Help.Utils

  test "node side" do
    x_node = Utils.useless_process()
    other_neuron = Utils.useless_process()

    {:ok, pid} = GenServer.start_link(InputNode, [other_neuron, self()])

    refute_receive {:fire, _, _}
    InputNode.fire(pid, x_node, 0.6)
    assert_receive {:fire, _, 0.6}
  end

  test "x side" do
    neuron_a = Utils.useless_process()
    neuron_b = Utils.useless_process()

    {:ok, pid} = GenServer.start_link(InputNode, [neuron_a, neuron_b])

    InputNode.fire(pid, self(), 0.6)
    refute_receive {:back_propagate, _, _}
    send(pid, {:back_propagate, neuron_a, 0.2})
    refute_receive {:back_propagate, _, _}
    send(pid, {:back_propagate, neuron_b, 0.1})
    assert_receive {:back_propagate, _, 0.30000000000000004}

    InputNode.fire(pid, self(), 0.8)
    refute_receive {:back_propagate, _, _}
    send(pid, {:back_propagate, neuron_b, 0.1})
    refute_receive {:back_propagate, _, _}
    send(pid, {:back_propagate, neuron_b, 0.1})
    refute_receive {:back_propagate, _, _}
    send(pid, {:back_propagate, neuron_a, 0.7})
    assert_receive {:back_propagate, _, 0.7999999999999999}
  end

end
