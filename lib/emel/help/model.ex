defmodule Emel.Help.Model do

  import Integer, only: [is_odd: 1]

  alias Emel.Help.Utils

  @doc """
  Trims and parses the `string` into a float.

  """
  def parse(string) do
    {parsed, ""} = string
                   |> String.trim()
                   |> Float.parse()
    parsed
  end

  @doc """
  Returns a function that transforms a value of a _continuous attribute_ to a value of a _discrete attribute_.

  ## Examples

      iex> f = Emel.Help.Model.categorizer(["small", 7.0, "moderate", 12.0, "large"])
      ...> f.(8.0)
      "moderate"

      iex> f = Emel.Help.Model.categorizer(["small", 7.0, "moderate", 12.0, "large"])
      ...> f.(6.0)
      "small"

      iex> f = Emel.Help.Model.categorizer(["non positive", 0.0, "positive"])
      ...> f.(-0.3)
      "non positive"

      iex> f = Emel.Help.Model.categorizer(["non positive", 0.0, "positive"])
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

  @doc """
  Returns a two-element tuple.
  The first element, is the `dataset` on which the _feature scaling_ has been applied.
  _Feature scaling_ is used on the `dataset`'s numeric values of `keys` in order to reduce them to a scale between 0 and 1.
  The second element, is the inversion of the _feature scaling_ function.

  ## Examples

      iex> {normalized_rows, f} = Emel.Help.Model.normalize([%{a: 0}, %{a: 1}], [:a])
      ...> {normalized_rows, f.(%{a: 0})}
      {[%{a: 0.0}, %{a: 1.0}], %{a: 0}}

      iex> {normalized_rows, f} = Emel.Help.Model.normalize([%{"x" => 1}, %{"x" => 2}, %{"x" => 1.5}], ["x"])
      ...> {normalized_rows, f.(%{"x" => 0.5})}
      {[%{"x" => 0.0}, %{"x" => 1.0}, %{"x" => 0.5}], %{"x" => 1.5}}

      iex> {normalized_rows, f} = Emel.Help.Model.normalize([%{"x" => 1.0, "y" => -2.0, "z" => -4.0},
      ...>                                                   %{"x" => 2.0, "y" => 2.0, "z" => -8.0}],
      ...>                                                  ["y", "z"])
      ...> {normalized_rows, f.(%{"x" => 1.0, "y" => 0.0, "z" => 1.0})}
      {[%{"x" => 1.0, "y" => 0.0, "z" => 1.0},
        %{"x" => 2.0, "y" => 1.0, "z" => 0.0}],
       %{"x" => 1.0, "y" => -2.0, "z" => -4.0}}

  """
  def normalize(dataset, keys) do
    fs_by_key = dataset
                |> hd()
                |> Map.keys()
                |> Enum.map(
                     fn k ->
                       case Enum.member?(keys, k) do
                         true ->
                           vals = Enum.map(dataset, fn row -> row[k] end)
                           min_val = Enum.min(vals)
                           max_val = Enum.max(vals)
                           {
                             k,
                             {
                               fn v -> (v - min_val) / (max_val - min_val) end,
                               fn v -> min_val - v * min_val + v * max_val end
                             }
                           }
                         false ->
                           {k, {&Utils.identity/1, &Utils.identity/1}}
                       end
                     end
                   )
                |> Map.new()
    normalized_rows = for row <- dataset do
      row
      |> Enum.map(
           fn {k, v} ->
             {f, _} = fs_by_key[k]
             {k, f.(v)}
           end
         )
      |> Map.new()
    end
    inverse = fn row ->
      row
      |> Enum.map(
           fn {k, v} ->
             {_, f} = fs_by_key[k]
             {k, f.(v)}
           end
         )
      |> Map.new()
    end
    {normalized_rows, inverse}
  end

  @doc """
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
