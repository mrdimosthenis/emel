defmodule Ml.Net.NeuronTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.Neuron
  alias Ml.Net.Neuron
  alias Help.Utils

  test "double input - single output" do
    x_pid_a = Utils.useless_process()
    x_pid_b = Utils.useless_process()
    y_pid = self()

    {:ok, neuron} = GenServer.start_link(Neuron, [2, 1, 0.5])
    Neuron.set_ws(neuron, [0.5, 0.5])
    Neuron.set_x_pids(neuron, [x_pid_a, x_pid_b])
    Neuron.set_y_pids(neuron, [y_pid])

    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_a, 0.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 0.0})
    assert_receive {:fire, _, 0.5}

    assert Neuron.get_ws(neuron) == [0.5, 0.5]

    send(neuron, {:back_propagate, y_pid, 0.0})
    assert Neuron.get_ws(neuron) == [0.5, 0.5]

    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7310585786300049}

    send(neuron, {:back_propagate, y_pid, 0.7})
    assert Neuron.get_ws(neuron) == [0.4232233475965673, 0.4232233475965673]

    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.6998212248866079}

    send(neuron, {:back_propagate, y_pid, -0.9})
    assert Neuron.get_ws(neuron) == [0.5230001398259432, 0.5230001398259432]

    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7400061037414002}
  end

end
