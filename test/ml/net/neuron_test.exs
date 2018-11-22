defmodule Ml.Net.NeuronTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.Neuron
  alias Ml.Net.Neuron
  alias Ml.Net.InputNode
  alias Ml.Net.ErrorNode
  alias Ml.Net.FitNeuron
  alias Ml.Net.BiasNode

  test "neuron on XOR function" do
    {:ok, error_node} = GenServer.start_link(ErrorNode, 1)

    {:ok, fit_terminal_neuron} = GenServer.start_link(FitNeuron, [[0.5, 0.5, 0.5], 0.0001, [error_node]])


    {:ok, fit_neuron_a} = GenServer.start_link(FitNeuron, [[0.5, 0.5, 0.5], 0.0001, [fit_terminal_neuron]])
    {:ok, fit_neuron_b} = GenServer.start_link(FitNeuron, [[0.5, 0.5, 0.5], 0.0001, [fit_terminal_neuron]])
    {:ok, _} = GenServer.start_link(BiasNode, [fit_terminal_neuron])

    {:ok, input_node_a} = GenServer.start_link(InputNode, [fit_neuron_a, fit_neuron_b])
    {:ok, input_node_b} = GenServer.start_link(InputNode, [fit_neuron_a, fit_neuron_b])
    {:ok, _} = GenServer.start_link(BiasNode, [fit_neuron_a, fit_neuron_b])

    send(input_node_a, {:fire, self(), 0})
    refute_receive {:back_propagate, _, _}
    send(input_node_b, {:fire, self(), 0})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, fit_terminal_neuron, 0})
    assert_receive {:back_propagate, _, 0.03284572958030721}
    assert_receive {:back_propagate, _, 0.03284572958030721}

    send(input_node_a, {:fire, self(), 1})
    refute_receive {:back_propagate, _, _}
    send(input_node_b, {:fire, self(), 0})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, fit_terminal_neuron, 1})
    assert_receive {:back_propagate, _, -0.007772698519283291}
    assert_receive {:back_propagate, _, -0.007772698519283291}

    send(input_node_a, {:fire, self(), 0})
    refute_receive {:back_propagate, _, _}
    send(input_node_b, {:fire, self(), 1})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, fit_terminal_neuron, 1})
    assert_receive {:back_propagate, _, -0.007772615928359264}
    assert_receive {:back_propagate, _, -0.007772628011199327}

    send(input_node_a, {:fire, self(), 1})
    refute_receive {:back_propagate, _, _}
    send(input_node_b, {:fire, self(), 1})
    refute_receive {:back_propagate, _, _}
    send(error_node, {:fire_y, fit_terminal_neuron, 0})
    assert_receive {:back_propagate, _, 0.019600216869179003}
    assert_receive {:back_propagate, _, 0.01960021686950276}

    wait_back_propagate = fn ->
      Enum.each(
        1..2,
        fn _ ->
          receive do
            {:back_propagate, _, _} -> :ok
          end
        end
      )
    end

    for _ <- 1 .. 10000 do
      send(input_node_a, {:fire, self(), 0})
      send(input_node_b, {:fire, self(), 0})
      send(error_node, {:fire_y, fit_terminal_neuron, 0})
      wait_back_propagate.()

      send(input_node_a, {:fire, self(), 1})
      send(input_node_b, {:fire, self(), 0})
      send(error_node, {:fire_y, fit_terminal_neuron, 1})
      wait_back_propagate.()

      send(input_node_a, {:fire, self(), 0})
      send(input_node_b, {:fire, self(), 1})
      send(error_node, {:fire_y, fit_terminal_neuron, 1})
      wait_back_propagate.()

      send(input_node_a, {:fire, self(), 1})
      send(input_node_b, {:fire, self(), 1})
      send(error_node, {:fire_y, fit_terminal_neuron, 0})
      wait_back_propagate.()
    end

    terminal_weights = FitNeuron.get_weights(fit_terminal_neuron)
    neuron_a_weights = FitNeuron.get_weights(fit_neuron_a)
    neuron_b_weights = FitNeuron.get_weights(fit_neuron_b)

    assert terminal_weights == [0.26628779983831447, 0.26628779983831447, 0.16952519813522637]
    assert neuron_a_weights == [0.49272667025648476, 0.492726651660333, 0.4758581575187801]
    assert neuron_b_weights == [0.49272667025648476, 0.492726651660333, 0.4758581575187801]

#    {:ok, terminal_neuron} = GenServer.start_link(Neuron, [terminal_weights, [self()]])
#
#    {:ok, neuron_a} = GenServer.start_link(Neuron, [neuron_a_weights, [terminal_neuron]])
#    {:ok, neuron_b} = GenServer.start_link(Neuron, [neuron_b_weights, [terminal_neuron]])
#
#    {:ok, input_node_a} = GenServer.start_link(InputNode, [neuron_a, neuron_b])
#    {:ok, input_node_b} = GenServer.start_link(InputNode, [neuron_a, neuron_b])
#
#    {:ok, terminal_bias} = GenServer.start_link(BiasNode, [terminal_neuron])
#    {:ok, hidden_bias} = GenServer.start_link(BiasNode, [neuron_a, neuron_b])
#
#    fire_biases = fn ->
#      BiasNode.fire(terminal_bias)
#      BiasNode.fire(hidden_bias)
#    end
#
#    send(input_node_a, {:fire, self(), 0})
#    send(input_node_b, {:fire, self(), 0})
#    assert_receive {:fire, _, 0.48570317427986925}
#
#    fire_biases.()
#    send(input_node_a, {:fire, self(), 1})
#    send(input_node_b, {:fire, self(), 0})
#    assert_receive {:fire, _, 0.6446960120359124}

  end

end
