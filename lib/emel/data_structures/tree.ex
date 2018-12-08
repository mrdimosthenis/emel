defmodule Emel.DataStructures.Tree do

  defmodule Node do
    @moduledoc false
    defstruct [:content, :children]
  end

  @doc """
  Converts the `node` into a nice and visible tree for console printing.

  ## Examples

      iex> alias Emel.DataStructures.Tree.Node
      ...>
      ...> Emel.DataStructures.Tree.pretty(%Node{
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

      iex> alias Emel.DataStructures.Tree.Node
      ...>
      ...> Emel.DataStructures.Tree.paths(%Node{
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
  The result of invoking `f` on `node`'s `content` and `children`.

  ## Examples

      iex> alias Emel.DataStructures.Tree.Node
      ...>
      ...> Emel.DataStructures.Tree.map(%Node{
      ...>                           content: -2,
      ...>                           children: [
      ...>                             %Node{
      ...>                               content: 1
      ...>                             },
      ...>                             %Node{
      ...>                               children: [
      ...>                                 %Node{
      ...>                                   content: 2,
      ...>                                   children: [
      ...>                                     %Node{
      ...>                                       content: 3
      ...>                                     }
      ...>                                   ]
      ...>                                 }]
      ...>                             }]
      ...>                         },
      ...>                         fn x -> 3 * x end)
      %Emel.DataStructures.Tree.Node{
        content: -6,
        children: [
          %Emel.DataStructures.Tree.Node{
            content: 3
          },
          %Emel.DataStructures.Tree.Node{
            children: [
              %Emel.DataStructures.Tree.Node{
                content: 6,
                children: [
                  %Emel.DataStructures.Tree.Node{
                    content: 9
                  }]
              }
            ]
          }
        ]
      }

  """
  def map(%Node{content: content, children: nil}, f), do: %Node{content: f.(content)}
  def map(%Node{content: nil, children: children}, f) do
    %Node{children: Enum.map(children, fn child -> map(child, f) end)}
  end
  def map(%Node{content: content, children: children}, f) do
    %Node{content: f.(content), children: Enum.map(children, fn child -> map(child, f) end)}
  end

  @doc """
  Recursively applies the `node`'s `content` to the `children`.

  ## Examples

      iex> alias Emel.DataStructures.Tree.Node
      ...>
      ...> Emel.DataStructures.Tree.apply(%Node{
      ...>                             content: fn _ -> 5 end
      ...>                           })
      5

      iex> alias Emel.DataStructures.Tree.Node
      ...>
      ...> Emel.DataStructures.Tree.apply(%Node{
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

      iex> alias Emel.DataStructures.Tree.Node
      ...>
      ...> Emel.DataStructures.Tree.apply(%Node{
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
