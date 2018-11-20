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

  def duplicate(x, n) when n > 0 do
    for _ <- 1..n do
      x
    end
  end

  def rand_float(n) do
    for _ <- 1..n do
      :rand.uniform()
    end
  end

  def useless_process(), do: spawn fn -> nil end

  def put_into_keylist(tuples, key, val) do
    if Enum.any?(tuples, fn {k, _} -> k == key end) do
      tuples
      |> Enum.reduce(
           [],
           fn ({k, v}, tpls) ->
             new_tpl = case k do
               ^key -> {k, val}
               _ -> {k, v}
             end
             [new_tpl | tpls]
           end
         )
      |> Enum.reverse()
    else
      [{key, val} | tuples]
    end
  end

  def println(obj) do
    obj
    |> inspect()
    |> IO.puts()
    IO.puts("")
  end

end
