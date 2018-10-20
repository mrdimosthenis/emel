defmodule Ml.ClassificationTree do
  @moduledoc ~S"""
  Uses a _decision tree_ to go from _observations_ about an item (represented in the branches)
  to conclusions about the item's a discrete set of values (represented in the leaves).

  """

  alias Math.Statistics, as: Statistics

  def entropy(dataset, class) do
    dataset
    |> Enum.group_by(fn row -> row[class] end)
    |> Map.values()
    |> Enum.map(fn rows -> length(rows) / length(dataset) end)
    |> Statistics.entropy()
  end

  def entropy(dataset, class, attribute) do
    dataset
    |> Enum.group_by(fn row -> row[attribute] end)
    |> Map.values()
    |> Enum.map(
         fn sub_dataset ->
           p = length(sub_dataset) / length(dataset)
           e = entropy(sub_dataset, class)
           p * e
         end
       )
    |> Enum.sum()
  end

  def information_gain(dataset, class, attribute) do
    entropy(dataset, class) - entropy(dataset, class, attribute)
  end

  defp select_attribute(dataset, class, attributes, selected_ones) do
    available_ones = attributes -- selected_ones
    case available_ones do
      [] -> {:error, :no_available_attributes}
      _ -> {:ok, Enum.max_by(available_ones, fn attr -> information_gain(dataset, class, attr) end)}
    end
  end

end
