defmodule Help.Model do
  @moduledoc false
  import Integer, only: [is_odd: 1]

  @doc ~S"""
  Trims and parses the `string` into a float

  """
  def parse(string) do
    {parsed, ""} = string
                   |> String.trim()
                   |> Float.parse()
    parsed
  end

  @doc ~S"""
  Returns a function that transforms a value of a _continuous attribute_ to a value of a _discrete attribute_.

  ## Examples

      iex> f = Help.Model.categorizer(["small", 7.0, "moderate", 12.0, "large"])
      ...> f.(8.0)
      "moderate"

      iex> f = Help.Model.categorizer(["small", 7.0, "moderate", 12.0, "large"])
      ...> f.(6.0)
      "small"

      iex> f = Help.Model.categorizer(["non positive", 0.0, "positive"])
      ...> f.(-0.3)
      "non positive"

      iex> f = Help.Model.categorizer(["non positive", 0.0, "positive"])
      ...> f.(0.0)
      "non positive"

  """
  def categorizer(categories_separated_by_thresholds) do
    thresholds = categories_separated_by_thresholds
                 |> Enum.with_index()
                 |> Enum.filter(fn {_, i} -> is_odd(i) end)
                 |> Enum.map(fn {v, _} -> v end)
    if Enum.any?(thresholds, fn x -> !is_number(x) end) || thresholds != Enum.sort(thresholds) do
      raise "Categories are not separated by valid thresholds"
    end
    fn value -> categories_separated_by_thresholds
                |> Enum.take_while(fn x -> !is_number(x) || value > x end)
                |> List.last()
    end
  end

  @doc ~S"""
  Applies _feature scaling_ on the `dataset`'s numeric values of `keys` and reduces them to a scale between 0 and 1.

  ## Examples

      iex> Help.Model.normalize([%{a: 0}, %{a: 1}], [:a])
      [%{a: 0.0}, %{a: 1.0}]

      iex> Help.Model.normalize([%{"x" => 1}, %{"x" => 2}, %{"x" => 1.5}], ["x"])
      [%{"x" => 0.0}, %{"x" => 1.0}, %{"x" => 0.5}]

      iex> Help.Model.normalize([%{"x" => 1, "y" => -2, "z" => -4}, %{"x" => 2, "y" => 2, "z" => -8}], ["y", "z"])
      [%{"x" => 1, "y" => 0.0, "z" => 1.0}, %{"x" => 2, "y" => 1.0, "z" => 0.0}]

  """
  def normalize(dataset, keys) do
    f_by_key = keys
               |> Enum.map(
                    fn k -> vals = Enum.map(dataset, fn row -> row[k] end)
                            min_val = Enum.min(vals)
                            max_val = Enum.max(vals)
                            {k, fn v -> (v - min_val) / (max_val - min_val) end}
                    end
                  )
               |> Map.new()
    for row <- dataset do
      row
      |> Enum.map(
           fn {k, v} -> case Enum.member?(keys, k) do
                          true -> {k, f_by_key[k].(v)}
                          false -> {k, v}
                        end
           end
         )
      |> Map.new()
    end
  end

  @doc ~S"""
  Separates the `dataset` into a `training set` and `testing set`.

  """
  def training_and_test_sets(dataset, ratio) when (ratio > 0 and ratio < 1) do
    l = length(dataset)
    n = trunc(l * ratio)
    dataset
    |> Enum.shuffle()
    |> Enum.split(n)
  end

end
