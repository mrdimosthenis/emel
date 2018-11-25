defmodule Ml.Net.WrapperTest do
  use ExUnit.Case
  doctest Ml.Net.Wrapper
  alias Ml.Net.Wrapper

  test "single input - single output - 3 single layers" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [1, 1, [1, 1, 1], 0.25])

    weights_1 = Wrapper.get_weights(wrapper)

    Wrapper.fit(wrapper, [0], [0])

    weights_2 = Wrapper.get_weights(wrapper)

    Wrapper.fit(wrapper, [0.5], [0.5])

    weights_3 = Wrapper.get_weights(wrapper)

    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "double input - double output - single layer" do
#    {:ok, wrapper} = GenServer.start_link(Wrapper, [2, 1, [1], 0.25])
#
#    weights_1 = Wrapper.get_weights(wrapper)
#
#    Wrapper.fit(wrapper, [0.1, 0.9], [0.9])
#
#    weights_2 = Wrapper.get_weights(wrapper)
#
#    Wrapper.fit(wrapper, [0.3, 0.8], [0.8])
#
#    weights_3 = Wrapper.get_weights(wrapper)
#
#    assert weights_1 != weights_2 && weights_2 != weights_3
  end

end
