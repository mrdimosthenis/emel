defmodule Help.DatasetManipulation do
  @moduledoc false
  import Integer, only: [is_odd: 1]

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

  def load_dataset(path, columns_of_interest) do
    path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(fn row -> Map.take(row, columns_of_interest) end)
  end

end
