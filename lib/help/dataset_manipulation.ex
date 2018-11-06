defmodule Help.DatasetManipulation do
  @moduledoc false
  import Integer, only: [is_odd: 1]
  alias Help.Utils

  # IO

  def load_dataset(path) do
    path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&Utils.identity/1)
  end
  def load_dataset(path, columns_of_interest) do
    path
    |> load_dataset()
    |> Enum.map(fn row -> Map.take(row, columns_of_interest) end)
  end

  def save_dataset([r | _] = dataset, path) do
    headers = Map.keys(r)
    rows = Enum.map(dataset, fn row -> Utils.map_vals(row, headers) end)
    file = File.open!(path, [:write, :utf8])
    [headers | rows]
    |> CSV.encode
    |> Enum.each(&IO.write(file, &1))
    File.close(file)
  end

  # modify

  def parse(s) do
    {parsed, ""} = Float.parse(s)
    parsed
  end

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

  # model

  def training_and_test_sets(dataset, ratio) do
    l = length(dataset)
    n = trunc(l * ratio)
    dataset
    |> Enum.shuffle()
    |> Enum.split(n)
  end

  def accuracy(vector_a, vector_b) when length(vector_a) == length(vector_b) do
    n = Enum.zip(vector_a, vector_b)
        |> Enum.count(fn {a, b} -> a == b end)
    n / length(vector_b)
  end

end
