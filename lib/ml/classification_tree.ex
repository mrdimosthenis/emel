defmodule Ml.ClassificationTree do
  @moduledoc ~S"""
  Uses a _decision tree_ to go from _observations_ about an item (represented in the branches)
  to conclusions about the item's a discrete set of values (represented in the leaves).

  """

  alias Math.Statistics, as: Statistics

  def entropy(dataset, attribute) do
    dataset
    |> Enum.group_by(fn row -> row[attribute] end)
    |> Map.values()
    |> Enum.map(fn rows -> length(rows) / length(dataset) end)
    |> Statistics.entropy()
  end

  def entropy(dataset, target_attribute, attribute) do
    dataset
    |> Enum.group_by(fn row -> row[attribute] end)
    |> Map.values()
    |> Enum.map(
         fn sub_dataset ->
           p = length(sub_dataset) / length(dataset)
           e = entropy(sub_dataset, target_attribute)
           p * e
         end
       )
    |> Enum.sum()
  end

  def information_gain(dataset, target_attribute, attribute) do
    entropy(dataset, target_attribute) - entropy(dataset, target_attribute, attribute)
  end

  def select_attribute(dataset, target_attribute, attributes, selected_ones) do
    available_ones = attributes -- selected_ones
    case available_ones do
      [] -> {:error, :no_available_attributes}
      _ -> {:ok, Enum.max_by(available_ones, fn attr -> information_gain(dataset, target_attribute, attr) end)}
    end
  end

end
