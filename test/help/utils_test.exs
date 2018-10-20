defmodule Help.UtilsTest do
  @moduledoc false
  use ExUnit.Case
  doctest Help.Utils
  import Help.Utils

  @leaf_a %Help.Utils.TreeNode{
    children: [],
    content: %{
      class: "y"
    }
  }
  @leaf_b %Help.Utils.TreeNode{
    children: [],
    content: %{
      class: "n"
    }
  }
  @node %Help.Utils.TreeNode{
    children: [@leaf_a, @leaf_b],
    content: %{
      value: "f"
    }
  }

  test "pretty tree" do
    assert pretty_tree(@leaf_a) == %{class: "y"}
    assert pretty_tree(@node) == {%{value: "f"}, [%{class: "y"}, %{class: "n"}]}
  end

end
