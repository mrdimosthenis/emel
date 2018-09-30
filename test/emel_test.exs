defmodule EmelTest do
  use ExUnit.Case
  doctest Emel

  test "greets the world" do
    assert Emel.hello() == :world
  end
end
