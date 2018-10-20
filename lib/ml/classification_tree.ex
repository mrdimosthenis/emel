defmodule Ml.ClassificationTree do
  @moduledoc ~S"""
  Uses a _decision tree_ to go from _observations_ about an item (represented in the branches)
  to conclusions about the item's a discrete set of values (represented in the leaves).

  """

  alias Help.Utils, as: Utils
  alias Math.Statistics, as: Statistics

  def entropy(dataset, class_attr) do
    dataset
    |> Enum.group_by(fn row -> row[class_attr] end)
    |> Map.values()
    |> Enum.map(fn rows -> length(rows) / length(dataset) end)
    |> Statistics.entropy()
  end

  def entropy(dataset, class_attr, attribute) do
    dataset
    |> Enum.group_by(fn row -> row[attribute] end)
    |> Map.values()
    |> Enum.map(
         fn sub_dataset ->
           p = length(sub_dataset) / length(dataset)
           e = entropy(sub_dataset, class_attr)
           p * e
         end
       )
    |> Enum.sum()
  end

  def information_gain(dataset, class_attr, attribute) do
    entropy(dataset, class_attr) - entropy(dataset, class_attr, attribute)
  end

  defp exausted_attributes(dataset, class_attr) do
    %Utils.Pair{first: fst, second: _} = dataset
                                         |> Enum.group_by(fn row -> row[class_attr] end)
                                         |> Enum.map(fn {k, v} -> %Utils.Pair{first: k, second: length(v)} end)
                                         |> Enum.sort_by(&(&1.second), &>=/2)
                                         |> Enum.at(0)
    %Utils.TreeNode{
      content: %{
        class: fst
      },
      children: []
    }
  end

  defp same_class([row | _], class_attr) do
    %Utils.TreeNode{
      content: %{
        class: row[class_attr]
      },
      children: []
    }
  end

  defp break_down(dataset, class_attr, non_selected_attrs) do
    [selected_attr | rest_attrs] = Enum.sort_by(
      non_selected_attrs,
      &(information_gain(dataset, class_attr, &1)),
      &>=/2
    )
    grouped_by_attr = Enum.group_by(dataset, fn row -> row[selected_attr] end)
    %Utils.TreeNode{
      content: %{
        attribute: selected_attr
      },
      children: Enum.map(
        grouped_by_attr,
        fn {k, v} -> %Utils.TreeNode{
                       content: %{
                         value: k
                       },
                       children: decision_tree(v, class_attr, rest_attrs)
                     }
        end
      )
    }
  end

  def decision_tree(dataset, class_attr, non_selected_attrs) do
    grouped_by_class = Enum.group_by(dataset, fn row -> row[class_attr] end)
    tree = cond do
      Enum.empty?(non_selected_attrs) -> exausted_attributes(dataset, class_attr)
      Enum.count(grouped_by_class) == 1 -> same_class(dataset, class_attr)
      true -> break_down(dataset, class_attr, non_selected_attrs)
    end
    [tree]
  end

end
