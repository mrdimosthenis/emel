defmodule Emel.Ml.Net.WrapperTest do
  use ExUnit.Case
  doctest Emel.Ml.Net.Wrapper
  alias Emel.Ml.Net.Wrapper

  test "single input - single output - 3 single layers" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [[[[0.5, 0.5]], [[0.5, 0.5]], [[0.5, 0.5]]], 1])
    assert Wrapper.predict(wrapper, [0]) == [0.6997664024351756]
    assert Wrapper.predict(wrapper, [0.4]) == [0.7002754627158335]
    assert Wrapper.predict(wrapper, [1]) == [0.7009670875230228]
  end

  test "single input - single output - 1 single layer" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [[[[0.5, 0.5]]], 1])
    assert Wrapper.predict(wrapper, [0]) == [0.6224593312018546]
    assert Wrapper.predict(wrapper, [0.4]) == [0.6681877721681662]
    assert Wrapper.predict(wrapper, [1]) == [0.7310585786300049]
  end

  test "double input - single output - 1 single layer" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [[[[0.1, 0.1, 0.1]]], 1])
    assert Wrapper.predict(wrapper, [0, 0]) == [0.52497918747894]
    assert Wrapper.predict(wrapper, [0.4, 0.6]) == [0.549833997312478]
    assert Wrapper.predict(wrapper, [1, 1]) == [0.574442516811659]
  end

  test "5 inputs - single output - 1 single layer" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [[[[0.8, 0.9, 0.8, 0.9, 0.8, 0.9]]], 1])
    assert Wrapper.predict(wrapper, [0.1, 0.2, 0.1, 0.2, 0.1]) == [0.8175744761936437]
    assert Wrapper.predict(wrapper, [0.4, 0.5, 0.6, 0.5, 0.4]) == [0.9488262990829084]
    assert Wrapper.predict(wrapper, [0.9, 0.8, 0.9, 0.9, 0.8]) == [0.9891211899829261]
  end

  test "double input - double output - 1 double layer" do
    {:ok, wrapper} = GenServer.start_link(Wrapper, [[[[0.5, 0.5, 0.5], [0.5, 0.5, 0.5]]], 2])
    assert Wrapper.predict(wrapper, [0, 0]) == [0.6224593312018546, 0.6224593312018546]
    assert Wrapper.predict(wrapper, [0.4, 0.6]) == [0.7310585786300049, 0.7310585786300049]
    assert Wrapper.predict(wrapper, [1, 1]) == [0.8175744761936437, 0.8175744761936437]
  end

  test "triple input - triple output - deep neural net" do
    weights = [
      [
        [0.3234213840855802, 0.9466930239727829, 0.29530383166458396, 0.05539594249793724],
        [0.17263083334557294, 0.37384770733925027, 0.004185278453070125, 0.6419238420807047],
        [0.49239425448470675, 0.7462203137783805, 0.9380749468111387, -0.0011150825434494242],
        [0.1177590497972625, 0.7465642304223791, 0.2841221699301489, 0.14320586885346323]
      ],
      [
        [0.008272793843181185, 0.5684009378183318, 0.19317005767344889, 0.7020355198467835, 0.26165415187056174],
        [0.3944733371384399, 0.8454628978403415, 0.7201139781137277, 0.25012978073619235, 0.4714916309474708],
        [0.7367967190740784, 0.9446704824023856, 0.1738237493175224, 0.9140021571838518, 0.20721722207570956],
        [0.8232324234043635, 0.863954716340794, 0.4451307441097338, 0.32207908639159133, 0.839134948785656],
        [0.5903004127587942, 0.7533804096960396, 0.816348660364613, 0.6496048145790538, 0.6778670950055368]
      ],
      [
        [0.8080912632553229, 0.861449009570066, 0.19003485643203635, 0.8541871344185655, 0.7912952949527046, 0.3881813897530828],
        [0.98551257321185, 0.671999558362266, 0.21172084124230436, 0.45599662761931054, 0.9551610688394084, 0.06259601800691847],
        [0.3430538608563848, 0.6273860533004315, 0.46597640293255027, 0.14589862191793346, 0.2015916241797346, 0.677895553380759]
      ]
    ]
    {:ok, wrapper} = GenServer.start_link(Wrapper, [weights, 3])
    assert Wrapper.predict(wrapper, [0, 0, 0]) == [0.9669096497890777, 0.9442367580593184, 0.8985056338134829]
    assert Wrapper.predict(wrapper, [1, 1, 1]) == [0.9722822968558212, 0.9526983202149728, 0.9073923679584168]
    assert Wrapper.predict(wrapper, [0, 1, 0.5]) == [0.9711749773113452, 0.9509516688760772, 0.9055108810789647]
    assert Wrapper.predict(wrapper, [1, 0, 0.5]) == [0.9694675196041916, 0.9481891513599587, 0.9025437979621386]
    assert Wrapper.predict(wrapper, [0, 0, 0]) == [0.9669096497890777, 0.9442367580593184, 0.8985056338134829]
    assert Wrapper.predict(wrapper, [1, 1, 1]) == [0.9722822968558212, 0.9526983202149728, 0.9073923679584168]
  end

end
