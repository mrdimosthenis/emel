defmodule DataStructures.Tree do

  defmodule Node do
    @moduledoc false
    defstruct [:content, :children]
  end

  @doc """
  Converts the `node` into a nice and visible tree for console printing.

  ## Examples

      iex> alias DataStructures.Tree.Node
      ...>
      ...> DataStructures.Tree.pretty(%Node{
      ...>                              content: "root",
      ...>                              children: [
      ...>                                %Node{
      ...>                                content: :leaf
      ...>                              },
      ...>                                %Node{
      ...>                                  children: [
      ...>                                    %Node{
      ...>                                      content: "second_level",
      ...>                                      children: [
      ...>                                        %Node{
      ...>                                          content: 0
      ...>                                        }
      ...>                                      ]
      ...>                                    }]
      ...>                                }]
      ...>                            })
      [
        "root",
        [
          :leaf,
          [
            [
              "second_level",
              [
                0
              ]
            ]
          ]
        ]
      ]

  """
  def pretty(%Node{content: content, children: nil}), do: content
  def pretty(%Node{content: nil, children: children}), do: Enum.map(children, &pretty/1)
  def pretty(%Node{content: content, children: children}), do: [content, Enum.map(children, &pretty/1)]

  defp expand(%Node{content: content, children: nil}, path), do: [[content | path]]
  defp expand(%Node{content: content, children: children}, path) do
    Enum.flat_map(
      children,
      fn child ->
        expand(child, [content | path])
      end
    )
  end

  @doc """
  The sequences of nodes connecting the `tree`'s root with the leafs.

  ## Examples

      iex> alias DataStructures.Tree.Node
      ...>
      ...> DataStructures.Tree.paths(%Node{
      ...>                             content: "root",
      ...>                             children: [
      ...>                               %Node{
      ...>                               content: :leaf
      ...>                             },
      ...>                               %Node{
      ...>                                 children: [
      ...>                                   %Node{
      ...>                                     content: "second_level",
      ...>                                     children: [
      ...>                                       %Node{
      ...>                                         content: 0
      ...>                                       }
      ...>                                     ]
      ...>                                   }]
      ...>                               }]
      ...>                           })
      [["root", :leaf],
       ["root", nil, "second_level", 0]]

  """
  def paths(tree) do
    tree
    |> expand([])
    |> Enum.map(&Enum.reverse/1)
  end

  @doc """
  Recursively applies the `node`'s `content` to the `children`.

  ## Examples

      iex> alias DataStructures.Tree.Node
      ...>
      ...> DataStructures.Tree.apply(%Node{
      ...>                             content: fn _ -> 5 end
      ...>                           })
      5

      iex> alias DataStructures.Tree.Node
      ...>
      ...> DataStructures.Tree.apply(%Node{
      ...>                             content: fn [x, y] -> x * y end,
      ...>                             children: [
      ...>                               %Node{
      ...>                                 content: fn _ -> 7 end
      ...>                               },
      ...>                               %Node{
      ...>                                 content: fn _ -> 2 end
      ...>                               }
      ...>                             ]
      ...>                           })
      14

      iex> alias DataStructures.Tree.Node
      ...>
      ...> DataStructures.Tree.apply(%Node{
      ...>                             content: fn [x, y] -> x + y end,
      ...>                             children: [
      ...>                               %Node{
      ...>                                 content: fn [x] -> x * x end,
      ...>                                 children: [
      ...>                                   %Node{
      ...>                                     content: fn _ -> 3 end
      ...>                                   }
      ...>                                 ]
      ...>                               },
      ...>                               %Node{
      ...>                                 content: fn _ -> 2 end
      ...>                               }
      ...>                             ]
      ...>                           })
      11

  """
  def apply(%Node{content: f, children: children}) do
    coll = children || []
    coll
    |> Enum.map(&apply/1)
    |> f.()
  end

end
