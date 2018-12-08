defmodule Emel.Ml.Net.FitWrapperTest do
  use ExUnit.Case
  doctest Emel.Ml.Net.FitWrapper
  alias Emel.Ml.Net.FitWrapper

  test "single input - single output - 3 single layers" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [1, 1, [1, 1, 1], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0], [0])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0.5], [0.5])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "single input - single output - 1 single layer" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [1, 1, [1], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0], [0])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0.5], [0.5])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "double input - single output - 1 single layer" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [2, 1, [1], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0, 0.5], [0])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0.5, 0], [0.5])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "5 inputs - single output - 1 single layer" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [5, 1, [1], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0, 0, 0, 0, 0], [0])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0.5, 0.5, 0.5, 0.5, 0.5], [0.5])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "5 inputs - single output - 4 single layers" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [5, 1, [1, 1, 1, 1], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0, 0, 0, 0, 0], [0])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0.5, 0.5, 0.5, 0.5, 0.5], [0.5])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "double input - double output - 1 double layer" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [2, 2, [2], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0, 1], [0, 1])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [1, 0], [0.5, 1])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

  test "triple input - triple output - deep neural net" do
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [3, 3, [4, 5, 3], 0.25])
    weights_1 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [0, 1, 0.5], [0, 1, 0.5])
    weights_2 = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.fit(fit_wrapper, [1, 0, 0.5], [0.5, 1, 0.5])
    weights_3 = FitWrapper.get_weights(fit_wrapper)
    assert weights_1 != weights_2 && weights_2 != weights_3
  end

end
