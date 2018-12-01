defmodule Ml.Net.OutputNodeTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.OutputNode
  alias Ml.Net.OutputNode
  alias Help.Utils

  test "single input" do
    x_pid = Utils.useless_process()
    y_pid = self()

    {:ok, output_node} = GenServer.start_link(OutputNode, 1)
    OutputNode.set_x_pids(output_node, [x_pid])
    OutputNode.set_y_pid(output_node, y_pid)

    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid, 0.8})
    assert_receive {:fire, _, [0.8]}

    send(output_node, {:fire, x_pid, 0.6})
    assert_receive {:fire, _, [0.6]}

    send(output_node, {:fire, x_pid, 0.4})
    assert_receive {:fire, _, [0.4]}
  end

  test "triple input" do
    x_pid_a = Utils.useless_process()
    x_pid_b = Utils.useless_process()
    x_pid_c = Utils.useless_process()
    y_pid = self()

    {:ok, output_node} = GenServer.start_link(OutputNode, 3)
    OutputNode.set_x_pids(output_node, [x_pid_a, x_pid_b, x_pid_c])
    OutputNode.set_y_pid(output_node, y_pid)

    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_a, 0.8})
    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_b, 0.4})
    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_c, 0.9})
    assert_receive {:fire, _, [0.8, 0.4, 0.9]}

    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_a, 0.3})
    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_b, 0.4})
    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_c, 0.9})
    assert_receive {:fire, _, [0.3, 0.4, 0.9]}

    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_a, 0.3})
    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_b, 0.4})
    refute_receive {:fire, _, _}
    send(output_node, {:fire, x_pid_c, 0.95})
    assert_receive {:fire, _, [0.3, 0.4, 0.95]}
  end

end
