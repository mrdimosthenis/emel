defmodule Help.Utils do
  @moduledoc false

  def log(x, b), do: :math.log(x) / :math.log(b)

  def identity(x), do: x

  def map_vals(map, keys), do: Enum.map(keys, fn k -> map[k] end)

  def vals_map(keys, vals) do
    Enum.zip(keys, vals)
    |> Map.new()
  end

  def update_map(map, keys, f) do
    Enum.reduce(
      map,
      %{},
      fn ({k, v}, acc) ->
        new_v = case Enum.member?(keys, k) do
          true -> f.(v)
          false -> v
        end
        Map.put(acc, k, new_v)
      end
    )
  end

  def indices([]), do: []
  def indices(ls), do: Enum.map(0..length(ls) - 1, &identity/1)

  def duplicate(x, n) when n > 1 do
    for _ <- 1..n do
      x
    end
  end

end
