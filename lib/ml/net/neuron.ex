defmodule Ml.Net.Neuron do
  @moduledoc false

  alias Help.Utils
  alias Math.Geometry
  alias Math.Calculus

  def start_link(num_of_inputs, learning_rate, ys_ids) do
    a = learning_rate
    ws = Utils.rand_float(num_of_inputs)
    x_by_pid = %{}
    nils = Utils.duplicate(nil, length(ys_ids))
    d_by_pid = Enum.zip(ys_ids, nils)
               |> Map.new()
    Task.start_link(fn -> loop({ws, x_by_pid, d_by_pid, a}) end)
  end

  defp fire_ys({ws, x_by_pid, d_by_pid, _}) do
    y = x_by_pid
        |> Enum.sort_by(fn {id, _} -> id end)
        |> Enum.map(fn {_, x} -> x end)
        |> Geometry.dot_product(ws)
        |> Calculus.logistic_function()
    Enum.each(d_by_pid, fn {pid, _} -> send pid, {:x, y, self()} end)
  end

  defp fire_xs({ws, x_by_pid, d_by_pid, a}) do
    common_factor = d_by_pid
                    |> Map.values()
                    |> Enum.sum()
                    |> Calculus.logistic_derivative()
    sorted_pids_with_xs = Enum.sort_by(x_by_pid, fn {pid, _} -> pid end)
    sorted_pids_with_xs
    |> Enum.map(fn {pid, _} -> pid end)
    |> Enum.zip(ws)
    |> Enum.each(fn {pid, w} -> send pid, {:y, common_factor * w, self()} end)
    new_ws = sorted_pids_with_xs
             |> Enum.map(fn {_, x} -> x end)
             |> Enum.zip(ws)
             |> Enum.map(fn {x, w} -> w - a * common_factor * x end)
    new_x_by_pid = %{}
    new_d_by_pid = d_by_pid
                   |> Enum.map(fn {pid, _} -> {pid, nil} end)
                   |> Map.new()
    loop({new_ws, new_x_by_pid, new_d_by_pid, a})
  end

  defp maybe_act({ws, x_by_pid, d_by_pid, _} = state) do
    cond do
      Enum.count(x_by_pid) == length(ws) -> fire_ys(state)
      Enum.all?(d_by_pid, fn {_, d} -> d != nil end) -> fire_xs(state)
      true -> nil
    end
  end

  defp loop({ws, x_by_pid, d_by_pid, a} = state) do
    maybe_act(state)
    receive do
      {:x, x, caller} ->
        new_x_by_pid = Map.put(x_by_pid, caller, x)
        loop({ws, new_x_by_pid, d_by_pid, a})
      {:y, d, caller} ->
        new_d_by_pid = %{d_by_pid | caller => d}
        loop({ws, x_by_pid, new_d_by_pid, a})
    end
  end

end
