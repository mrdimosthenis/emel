defmodule Ml.Net.ErrorNodeTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.ErrorNode
  alias Ml.Net.ErrorNode
  alias Help.Utils

  test "single output - neuron side" do
    input_node = Utils.useless_process()
    neuron = self()

    {:ok, error_node} = GenServer.start_link(ErrorNode, 1)
    ErrorNode.set_x_pids(error_node, [neuron])
    ErrorNode.set_y_pids(error_node, [input_node])

    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node, 0.85})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron, 0.85})
    assert_receive {:back_propagate, _, 0.0}

    send(error_node, {:fire_y, input_node, 0.6})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron, 0.85})
    assert_receive {:back_propagate, _, 0.5}

    send(error_node, {:fire, neuron, 0.6})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node, 0.85})
    assert_receive {:back_propagate, _, -0.5}
  end

  test "triple output - input side" do
    input_node_a = Utils.useless_process()
    input_node_b = self()
    input_node_c = Utils.useless_process()
    neuron_a = Utils.useless_process()
    neuron_b = Utils.useless_process()
    neuron_c = Utils.useless_process()

    {:ok, error_node} = GenServer.start_link(ErrorNode, 3)
    ErrorNode.set_x_pids(error_node, [neuron_a, neuron_b, neuron_c])
    ErrorNode.set_y_pids(error_node, [input_node_a, input_node_b, input_node_c])

    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node_a, 0.85})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron_a, 0.85})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node_b, 0.6})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron_b, 0.85})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node_c, 0.6})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron_c, 0.6})

    assert_receive {:back_propagate, _, 0.5}

    send(error_node, {:fire_y, input_node_c, 0.85})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron_a, 0.6})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node_b, 1.0})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron_b, 0.0})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire, neuron_c, 0.85})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, input_node_a, 0.6})

    assert_receive {:back_propagate, _, -2.0}
  end

end
