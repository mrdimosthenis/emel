defmodule Help.UtilsTest do
  use ExUnit.Case
  doctest Help.Utils
  alias Help.Utils

  @leaf_a %Utils.TreeNode{
    content: %{
      class: "y"
    }
  }
  @leaf_b %Utils.TreeNode{
    content: %{
      class: "n"
    }
  }
  @node %Utils.TreeNode{
    children: [@leaf_a, @leaf_b],
    content: %{
      value: "f"
    }
  }

  test "pretty tree" do
    assert Utils.pretty_tree(@leaf_a) == %{class: "y"}
    assert Utils.pretty_tree(@node) == [%{value: "f"}, [%{class: "y"}, %{class: "n"}]]
  end

end
