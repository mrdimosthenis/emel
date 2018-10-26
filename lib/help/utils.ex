defmodule Help.Utils do
  @moduledoc false

  defmodule Pair do
    @enforce_keys [:first, :second]
    defstruct [:first, :second]
  end

  defmodule TreeNode do
    defstruct [:content, :children]
  end

  def pretty_tree(%TreeNode{content: content, children: nil}), do: content
  def pretty_tree(%TreeNode{content: nil, children: children}), do: Enum.map(children, &pretty_tree/1)
  def pretty_tree(%TreeNode{content: content, children: children}), do: {content, Enum.map(children, &pretty_tree/1)}

  defp expand(%TreeNode{content: content, children: nil}, path), do: [[content | path]]
  defp expand(%TreeNode{content: content, children: children}, path) do
    Enum.flat_map(
      children,
      fn child ->
        expand(child, [content | path])
      end
    )
  end

  def tree_paths(tree) do
    tree
    |> expand([])
    |> Enum.map(&Enum.reverse/1)
  end

  def log(x, b), do: :math.log(x) / :math.log(b)

  def identity(x), do: x


  def indices([]), do: []
  def indices(ls), do: Enum.map(0..length(ls) - 1, &identity/1)

end
