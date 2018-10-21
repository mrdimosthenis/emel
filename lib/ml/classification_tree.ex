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

  defp exhausted_attributes(dataset, class_attr) do
    %Utils.Pair{first: fst, second: _} = dataset
                                         |> Enum.group_by(fn row -> row[class_attr] end)
                                         |> Enum.map(fn {k, v} -> %Utils.Pair{first: k, second: length(v)} end)
                                         |> Enum.sort_by(&(&1.second), &>=/2)
                                         |> Enum.at(0)
    %Utils.TreeNode{
      content: %{
        class_attr => fst
      },
      children: []
    }
  end

  defp same_class([row | _], class_attr) do
    %Utils.TreeNode{
      content: %{
        class_attr => row[class_attr]
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
      content: nil,
      children: Enum.map(
        grouped_by_attr,
        fn {k, v} -> %Utils.TreeNode{
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

  @doc ~S"""
  The _decision tree_ built with _ID3 Algorithm_ for a `dataset` with discrete `attributes`.

  ## Examples

      iex> Ml.ClassificationTree.decision_tree([
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
        {%{outlook: "Overcast"}, [%{decision: "Yes"}]},
        {
          %{outlook: "Rain"},
          [[{%{wind: "Strong"}, [%{decision: "No"}]}, {%{wind: "Weak"}, [%{decision: "Yes"}]}]]
        },
        {
          %{outlook: "Sunny"},
          [[{%{humidity: "High"}, [%{decision: "No"}]}, {%{humidity: "Normal"}, [%{decision: "Yes"}]}]]
        }
      ]

      iex> Ml.ClassificationTree.decision_tree([
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
      ...>    ], :risk, [:collateral, :income, :debt, :credit_history])
      [
        {
          %{income: "high"},
          [
            [
              {%{credit_history: "bad"}, [%{risk: "moderate"}]},
              {%{credit_history: "good"}, [%{risk: "low"}]},
              {%{credit_history: "unknown"}, [%{risk: "low"}]}
            ]
          ]
        },
        {%{income: "low"}, [%{risk: "high"}]},
        {
          %{income: "moderate"},
          [
            [
              {%{credit_history: "bad"}, [%{risk: "high"}]},
              {%{credit_history: "good"}, [%{risk: "moderate"}]},
              {
                %{credit_history: "unknown"},
                [[{%{debt: "high"}, [%{risk: "high"}]}, {%{debt: "low"}, [%{risk: "moderate"}]}]]
              }
            ]
          ]
        }
      ]

  """
  def decision_tree(dataset, class, attributes) do
    [tree] = unfold_tree(dataset, class, attributes)
    Utils.pretty_tree(tree)
  end

end
