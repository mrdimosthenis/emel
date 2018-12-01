defmodule Ml.Net.WrapperTest do
  use ExUnit.Case
  doctest Ml.Net.Wrapper
  alias Ml.Net.Wrapper

  test "single input - single output - 3 single layers" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [[[[0.5, 0.5]], [[0.5, 0.5]], [[0.5, 0.5]]], 1])
    assert Wrapper.predict(wrapper, [0]) == [0.6997664024351756]
    assert Wrapper.predict(wrapper, [0.4]) == [0.7002754627158335]
    assert Wrapper.predict(wrapper, [1]) == [0.7009670875230228]
  end

end
