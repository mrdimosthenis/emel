defmodule Ml.Net.FitNeuronTest do
  use ExUnit.Case, async: true
  doctest Ml.Net.FitNeuron
  alias Ml.Net.FitNeuron
  alias Help.Utils

  test "double input - single output" do
    {:ok, pid} = GenServer.start_link(FitNeuron, [[0.5, 0.5], 0.5, [self()]])

    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, self(), 0.0)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, Utils.useless_process(), 0.0)
    assert_receive {:"$gen_cast", {:fire, _, 0.5}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    FitNeuron.back_propagate(pid, self(), 0.0)
    assert_receive {:"$gen_cast", {:back_propagate, _, 0.125}}
  end

  test "single input - double output" do
    temp_process = Utils.useless_process()

    {:ok, pid} = GenServer.start_link(FitNeuron, [[0.6], 0.5, [self(), temp_process]])

    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, self(), 0.5)
    assert_receive {:"$gen_cast", {:fire, _, 0.574442516811659}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    FitNeuron.back_propagate(pid, self(), 0.7)
    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    FitNeuron.back_propagate(pid, temp_process, 0.3)
    assert_receive {:"$gen_cast", {:back_propagate, _, 0.1179671599448891}}
  end

  test "triple input - single output" do
    temp_process_a = Utils.useless_process
    temp_process_b = Utils.useless_process

    {:ok, pid} = GenServer.start_link(FitNeuron, [[0.3, 0.5, 0.7], 0.01, [self()]])

    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, self(), 0.5)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, temp_process_a, 0.5)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, temp_process_b, 0.5)
    assert_receive {:"$gen_cast", {:fire, _, 0.679178699175393}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    FitNeuron.back_propagate(pid, self(), -0.9)
    assert_receive {:"$gen_cast", {:back_propagate, _, 0.1438502151395844}}

    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, self(), 0.5)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, temp_process_a, 0.5)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, temp_process_b, 0.5)
    assert_receive {:"$gen_cast", {:fire, _, 0.6788427753118986}}

    refute_receive {:"$gen_cast", {:back_propagate, _, _}}
    FitNeuron.back_propagate(pid, self(), 0.9)
    assert_receive {:"$gen_cast", {:back_propagate, _, 0.1436390632579956}}

    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, self(), 0.5)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, temp_process_a, 0.5)
    refute_receive {:"$gen_cast", {:fire, _, _}}
    FitNeuron.fire(pid, temp_process_b, 0.5)
    assert_receive {:"$gen_cast", {:fire, _, 0.6785066662080377}}
  end

end
