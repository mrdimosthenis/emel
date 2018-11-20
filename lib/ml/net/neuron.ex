defmodule Ml.Net.Neuron do
  @moduledoc false

  alias Help.Utils
  alias Math.Geometry
  alias Math.Calculus

  defmodule State do
    @moduledoc false
    defstruct [:ws, :x_by_pid, :ypids_with_ds, :a]
  end

  def start_link(num_of_inputs, learning_rate, ys_ids) do
    a = learning_rate
    ws = Utils.rand_float(num_of_inputs)
    x_by_pid = %{}
    nils = Utils.duplicate(nil, length(ys_ids))
    ypids_with_ds = Enum.zip(ys_ids, nils)
    state = %State{ws: ws, x_by_pid: x_by_pid, ypids_with_ds: ypids_with_ds, a: a}
    Task.start_link(fn -> loop(state) end)
  end

  defp forward(%State{ws: ws, x_by_pid: x_by_pid, ypids_with_ds: ypids_with_ds}) do
    y = x_by_pid
        |> Enum.sort_by(fn {id, _} -> id end)
        |> Enum.map(fn {_, x} -> x end)
        |> Geometry.dot_product(ws)
        |> Calculus.logistic_function()
    Enum.each(ypids_with_ds, fn {pid, _} -> send pid, {:x, y, self()} end)
  end

  defp backward(%State{ws: ws, x_by_pid: x_by_pid, ypids_with_ds: ypids_with_ds, a: a}) do
    common_factor = ypids_with_ds
                    |> Enum.map(fn {_, v} -> v end)
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
    new_ypids_with_ds = Enum.map(ypids_with_ds, fn {pid, _} -> {pid, nil} end)
    loop(%State{ws: new_ws, x_by_pid: new_x_by_pid, ypids_with_ds: new_ypids_with_ds, a: a})
  end

  defp maybe_act(%State{ws: ws, x_by_pid: x_by_pid, ypids_with_ds: ypids_with_ds} = state) do
    cond do
      Enum.all?(ypids_with_ds, fn {_, d} -> d != nil end) -> backward(state)
      Enum.count(x_by_pid) == length(ws) -> forward(state)
      true -> nil
    end
  end

  defp loop(%State{ws: ws, x_by_pid: x_by_pid, ypids_with_ds: ypids_with_ds, a: a} = state) do
    maybe_act(state)
    receive do
      {:x, x, caller} ->
        new_x_by_pid = Map.put(x_by_pid, caller, x)
        loop(%State{ws: ws, x_by_pid: new_x_by_pid, ypids_with_ds: ypids_with_ds, a: a})
      {:y, d, caller} ->
        new_ypids_with_ds = Utils.update_keyword_list(ypids_with_ds, caller, d)
        loop(%State{ws: ws, x_by_pid: x_by_pid, ypids_with_ds: new_ypids_with_ds, a: a})
    end
  end

end
