defmodule Ml.Net.ErrorNodeTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.ErrorNode
  alias Ml.Net.ErrorNode
  alias Help.Utils

  test "single output" do
    {:ok, pid} = GenServer.start_link(ErrorNode, 1)

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, self(), 0.85)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, self(), 0.85)
    assert_receive {:"$gen_cast", {:back_propagate, _, 0.0}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, self(), 0.6)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, self(), 0.85)
    assert_receive {:"$gen_cast", {:back_propagate, _, 0.5}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, self(), 0.85)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, self(), 0.6)
    assert_receive {:"$gen_cast", {:back_propagate, _, -0.5}}
  end

  test "triple output" do
    temp_process_a = Utils.useless_process()
    temp_process_b = Utils.useless_process()

    {:ok, pid} = GenServer.start_link(ErrorNode, 3)

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, temp_process_a, 0.85)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, temp_process_a, 0.85)

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, self(), 0.6)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, self(), 0.85)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, temp_process_b, 0.6)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, temp_process_b, 0.6)

    assert_receive {:"$gen_cast", {:back_propagate, _, 0.5}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, temp_process_a, 0.85)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, temp_process_a, 0.85)

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, self(), 1.0)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, self(), 0.0)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y(pid, temp_process_b, 0.6)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    ErrorNode.fire_y_hat(pid, temp_process_b, 0.6)

    assert_receive {:"$gen_cast", {:back_propagate, _, -2.0}}
  end

end
