defmodule Ml.Net.NeuronTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.Neuron
  alias Ml.Net.Neuron
  alias Ml.Net.InputNode
  alias Ml.Net.ErrorNode
  alias Ml.Net.FitNeuron

  test "neuron on XOR function" do
    {:ok, error_node} = GenServer.start_link(ErrorNode, 1)

    {:ok, fit_terminal_neuron} = GenServer.start_link(FitNeuron, [[0.5, 0.5], 0.1, [error_node]])

    {:ok, fit_neuron_a} = GenServer.start_link(FitNeuron, [[0.5, 0.5], 0.1, [fit_terminal_neuron]])
    {:ok, fit_neuron_b} = GenServer.start_link(FitNeuron, [[0.5, 0.5], 0.1, [fit_terminal_neuron]])

    {:ok, input_node_a} = GenServer.start_link(InputNode, [fit_neuron_a, fit_neuron_b])
    {:ok, input_node_b} = GenServer.start_link(InputNode, [fit_neuron_a, fit_neuron_b])

    send(input_node_a, {:fire, self(), 0})
    refute_receive {:back_propagate, _, _}
    send(input_node_b, {:fire, self(), 0})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, self, 0})
#    assert_receive {:back_propagate, _, _}

#    refute_receive {:back_propagate, _, _}
#
#    send(error_node, {:fire_y, self, 0})
#
#    assert_receive {:back_propagate, _, _}


  end

end
