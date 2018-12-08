defmodule Emel.Ml.Net.InputNodeTest do
  use ExUnit.Case, async: true
  doctest Emel.Ml.Net.InputNode
  alias Emel.Ml.Net.InputNode
  alias Emel.Help.Utils

  test "neuron side" do
    fit_wrapper_node = Utils.useless_process()
    neuron_a = self()
    neuron_b = Utils.useless_process()

    {:ok, input_node} = GenServer.start_link(InputNode, 2)
    InputNode.set_y_pids(input_node, [neuron_a, neuron_b])

    refute_receive {:fire, _, _}
    send(input_node, {:fire, fit_wrapper_node, 0.6})
    assert_receive {:fire, _, 0.6}
  end

  test "fit_wrapper side" do
    fit_wrapper_node = self()
    neuron_a = Utils.useless_process()
    neuron_b = Utils.useless_process()

    {:ok, input_node} = GenServer.start_link(InputNode, 2)
    InputNode.set_x_pid(input_node, fit_wrapper_node)
    InputNode.set_y_pids(input_node, [neuron_a, neuron_b])

    send(input_node, {:fire, fit_wrapper_node, 0.6})
    refute_receive {:back_propagate, _, _}
    send(input_node, {:back_propagate, neuron_a, 0.2})
    refute_receive {:back_propagate, _, _}
    send(input_node, {:back_propagate, neuron_b, 0.1})
    assert_receive {:back_propagate, _, 0.30000000000000004}

    send(input_node, {:fire, fit_wrapper_node, 0.8})
    refute_receive {:back_propagate, _, _}
    send(input_node, {:back_propagate, neuron_b, 0.1})
    refute_receive {:back_propagate, _, _}
    send(input_node, {:back_propagate, neuron_b, 0.1})
    refute_receive {:back_propagate, _, _}
    send(input_node, {:back_propagate, neuron_a, 0.7})
    assert_receive {:back_propagate, _, 0.7999999999999999}
  end

end
