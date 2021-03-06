defmodule Emel.Ml.DecisionTree do
  @moduledoc """
  Uses a _decision tree_ to go from _observations_ about an item (represented in the branches)
  to conclusions about the item's discrete target value (represented in the leaves).

  """

  alias Emel.Help.Utils
  alias Emel.Math.Statistics
  alias Emel.DataStructures.Tree
  alias Emel.DataStructures.Tree.Node

  defp entropy(dataset, class_attr) do
    dataset
    |> Enum.group_by(fn row -> row[class_attr] end)
    |> Map.values()
    |> Enum.map(fn rows -> length(rows) / length(dataset) end)
    |> Statistics.entropy()
  end

  defp entropy(dataset, class_attr, attribute) do
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

  defp information_gain(dataset, class_attr, attribute) do
    entropy(dataset, class_attr) - entropy(dataset, class_attr, attribute)
  end

  defp exhausted_attributes(dataset, class_attr) do
    {fst, _} = dataset
                                         |> Enum.group_by(fn row -> row[class_attr] end)
                                         |> Enum.map(fn {k, v} -> {k, length(v)} end)
                                         |> Enum.sort_by(fn {_, v} -> v end, &>=/2)
                                         |> hd()
    %Node{
      content: %{
        class_attr => fst
      }
    }
  end

  defp same_class([row | _], class_attr) do
    %Node{
      content: %{
        class_attr => row[class_attr]
      }
    }
  end

  defp break_down(dataset, class_attr, non_selected_attrs) do
    [selected_attr | rest_attrs] = Enum.sort_by(
      non_selected_attrs,
      &(information_gain(dataset, class_attr, &1)),
      &>=/2
    )
    grouped_by_attr = Enum.group_by(dataset, fn row -> row[selected_attr] end)
    %Node{
      children: Enum.map(
        grouped_by_attr,
        fn {k, v} -> %Node{
                       content: %{
                         selected_attr => k
                       },
                       children: unfold_tree(v, class_attr, rest_attrs)
                     }
        end
      )
    }
  end

  defp unfold_tree(dataset, class_attr, non_selected_attrs) do
    grouped_by_class = Enum.group_by(dataset, fn row -> row[class_attr] end)
    tree = cond do
      Enum.empty?(non_selected_attrs) -> exhausted_attributes(dataset, class_attr)
      Enum.count(grouped_by_class) == 1 -> same_class(dataset, class_attr)
      true -> break_down(dataset, class_attr, non_selected_attrs)
    end
    [tree]
  end

  @doc """
  The expanded _decision tree_ built with the _ID3 Algorithm_ for a `dataset` with discrete `attributes`.

  ## Examples

      iex> Emel.Ml.DecisionTree.decision_tree([
      ...>         %{outlook: "Sunny", temperature: "Hot", humidity: "High", wind: "Weak", decision: "No"},
      ...>         %{outlook: "Sunny", temperature: "Hot", humidity: "High", wind: "Strong", decision: "No"},
      ...>         %{outlook: "Overcast", temperature: "Hot", humidity: "High", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Mild", humidity: "High", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Cool", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Cool", humidity: "Normal", wind: "Strong", decision: "No"},
      ...>         %{outlook: "Overcast", temperature: "Cool", humidity: "Normal", wind: "Strong", decision: "Yes"},
      ...>         %{outlook: "Sunny", temperature: "Mild", humidity: "High", wind: "Weak", decision: "No"},
      ...>         %{outlook: "Sunny", temperature: "Cool", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Mild", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Sunny", temperature: "Mild", humidity: "Normal", wind: "Strong", decision: "Yes"},
      ...>         %{outlook: "Overcast", temperature: "Mild", humidity: "High", wind: "Strong", decision: "Yes"},
      ...>         %{outlook: "Overcast", temperature: "Hot", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Mild", humidity: "High", wind: "Strong", decision: "No"}
      ...>    ], :decision, [:outlook, :temperature, :humidity, :wind])
      [
        [%{outlook: "Overcast"}, [%{decision: "Yes"}]],
        [
          %{outlook: "Rain"},
          [
            [
              [%{wind: "Strong"}, [%{decision: "No"}]],
              [%{wind: "Weak"}, [%{decision: "Yes"}]]
            ]
          ]
        ],
        [
          %{outlook: "Sunny"},
          [
            [
              [%{humidity: "High"}, [%{decision: "No"}]],
              [%{humidity: "Normal"}, [%{decision: "Yes"}]]
            ]
          ]
        ]
      ]

  """
  def decision_tree(dataset, class, attributes) do
    [tree] = unfold_tree(dataset, class, attributes)
    Tree.pretty(tree)
  end

  defp actual_rule_match(rule_maps, item, class) do
    Enum.find(
      rule_maps,
      fn rule ->
        keys = Map.keys(rule) -- [class]
        Map.take(rule, keys) == Map.take(item, keys)
      end
    )
  end

  defp nearest_rule_match(rule_maps, item, class) do
    Enum.max_by(
      rule_maps,
      fn rule ->
        keys = Map.keys(rule) -- [class]
        rule_vals = Utils.map_vals(rule, keys)
        item_vals = Utils.map_vals(item, keys)
        Enum.zip(rule_vals, item_vals)
        |> Enum.count(fn {rule_value, item_value} -> rule_value == item_value end)
      end
    )
  end

  @doc """
  Returns the function that classifies an item by using the _ID3 Algorithm_.

  ## Examples

      iex> f = Emel.Ml.DecisionTree.classifier([
      ...>         %{risk: "high", collateral: "none", income: "low", debt: "high", credit_history: "bad"},
      ...>         %{risk: "high", collateral: "none", income: "moderate", debt: "high", credit_history: "unknown"},
      ...>         %{risk: "moderate", collateral: "none", income: "moderate", debt: "low", credit_history: "unknown"},
      ...>         %{risk: "high", collateral: "none", income: "low", debt: "low", credit_history: "unknown"},
      ...>         %{risk: "low", collateral: "none", income: "high", debt: "low", credit_history: "unknown"},
      ...>         %{risk: "low", collateral: "adequate", income: "high", debt: "low", credit_history: "unknown"},
      ...>         %{risk: "high", collateral: "none", income: "low", debt: "low", credit_history: "bad"},
      ...>         %{risk: "moderate", collateral: "adequate", income: "high", debt: "low", credit_history: "bad"},
      ...>         %{risk: "low", collateral: "none", income: "high", debt: "low", credit_history: "good"},
      ...>         %{risk: "low", collateral: "adequate", income: "high", debt: "high", credit_history: "good"},
      ...>         %{risk: "high", collateral: "none", income: "low", debt: "high", credit_history: "good"},
      ...>         %{risk: "moderate", collateral: "none", income: "moderate", debt: "high", credit_history: "good"},
      ...>         %{risk: "low", collateral: "none", income: "high", debt: "high", credit_history: "good"},
      ...>         %{risk: "high", collateral: "none", income: "moderate", debt: "high", credit_history: "bad"}
      ...>    ], [:collateral, :income, :debt, :credit_history], :risk)
      ...> f.(%{collateral: "none", income: "high", debt: "low", credit_history: "good"})
      "low"

  """
  def classifier(dataset, discrete_attributes, class) do
    [tree] = unfold_tree(dataset, class, discrete_attributes)
    rule_maps = for path <- Tree.paths(tree) do
      path
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce(&Map.merge/2)
    end
    fn item ->
      actual_rule = actual_rule_match(rule_maps, item, class)
      selected_rule = case actual_rule do
        nil -> nearest_rule_match(rule_maps, item, class)
        _ -> actual_rule
      end
      selected_rule[class]
    end
  end

end
