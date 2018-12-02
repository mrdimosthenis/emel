defmodule Ml.Net.NeuronTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.Neuron
  alias Ml.Net.Neuron
  alias Help.Utils

  test "double input - single output - y side - fitting" do
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

    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7310585786300049}

    send(neuron, {:back_propagate, y_pid, 0.7})
    assert Neuron.get_ws(neuron) == [0.4311858233654814, 0.4311858233654814]

    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7031559210394115}

    send(neuron, {:back_propagate, y_pid, -0.9})
    assert Neuron.get_ws(neuron) == [0.5251132756514642, 0.5251132756514642]

    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7408184008775683}

    send(neuron, {:fire, x_pid_a, 1.0})
    assert_receive {:fire, _, 0.7408184008775683}

    Neuron.unset_fit(neuron)

    send(neuron, {:back_propagate, y_pid, 0.0})
    assert Neuron.get_ws(neuron) == [0.5251132756514642, 0.5251132756514642]

    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7408184008775683}

    send(neuron, {:fire, x_pid_a, 1.0})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 1.0})
    assert_receive {:fire, _, 0.7408184008775683}
  end

  test "single input - double output - x side - fitting" do
    x_pid = self()
    y_pid_a = Utils.useless_process()
    y_pid_b = Utils.useless_process()

    {:ok, neuron} = GenServer.start_link(Neuron, [1, 2, 0.8])
    Neuron.set_ws(neuron, [0.5])
    Neuron.set_x_pids(neuron, [x_pid])
    Neuron.set_y_pids(neuron, [y_pid_a, y_pid_b])

    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid, 0.4})
    refute_receive {:fire, _, _}

    send(neuron, {:back_propagate, y_pid_a, 0.7})
    refute_receive {:back_propagate, _, _}
    send(neuron, {:back_propagate, y_pid_b, 0.1})
    assert_receive {:back_propagate, _, 0.09900662908474397}
  end

  test "double input - single output - y side - no fitting" do
    x_pid_a = Utils.useless_process()
    x_pid_b = Utils.useless_process()
    y_pid = self()

    {:ok, neuron} = GenServer.start_link(Neuron, [[0.65, 0.45], 1])
    Neuron.set_x_pids(neuron, [x_pid_a, x_pid_b])
    Neuron.set_y_pids(neuron, [y_pid])

    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_a, 0.7})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 0.8})
    assert_receive {:fire, _, 0.6931739493259501}

    assert Neuron.get_ws(neuron) == [0.65, 0.45]

    send(neuron, {:fire, x_pid_a, 0.1})
    refute_receive {:fire, _, _}
    send(neuron, {:fire, x_pid_b, 0.2})
    assert_receive {:fire, _, 0.538672605206508}

    assert Neuron.get_ws(neuron) == [0.65, 0.45]
  end

end
