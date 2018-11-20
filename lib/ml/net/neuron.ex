defmodule Ml.Net.Neuron do
  @moduledoc false

  alias Help.Utils
  alias Math.Geometry
  alias Math.Calculus

  defmodule State do
    @moduledoc false
    defstruct [:ws, :xpids_with_vals, :ypids_with_ds, :a, :status]
  end

  def start_link(num_of_inputs, learning_rate, ys_ids) do
    a = learning_rate
    ws = Utils.rand_float(num_of_inputs)
    xpids_with_vals = []
    nils = Utils.duplicate(nil, length(ys_ids))
    ypids_with_ds = Enum.zip(ys_ids, nils)
    state = %State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a, status: :wait_xpids}
    Task.start_link(fn -> loop(state) end)
  end

  defp forward(%State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a}) do
    y = xpids_with_vals
        |> Enum.map(fn {_, x} -> x end)
        |> Geometry.dot_product(ws)
        |> Calculus.logistic_function()
    Enum.each(ypids_with_ds, fn {ypid, _} -> send ypid, {:x, y, self()} end)
    loop(%State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a, status: :wait_dvals})
  end

  defp backward(%State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a}) do
    common_factor = ypids_with_ds
                    |> Enum.map(fn {_, d} -> d end)
                    |> Enum.sum()
                    |> Calculus.logistic_derivative()
    xpids_with_vals
    |> Enum.map(fn {xpid, _} -> xpid end)
    |> Enum.zip(ws)
    |> Enum.each(fn {xpid, w} -> send xpid, {:y, common_factor * w, self()} end)
    new_ws = xpids_with_vals
             |> Enum.map(fn {_, x} -> x end)
             |> Enum.zip(ws)
             |> Enum.map(fn {x, w} -> w - a * common_factor * x end)
    new_xpids_with_vals = Enum.map(xpids_with_vals, fn {xpid, _} -> {xpid, nil} end)
    new_ypids_with_ds = Enum.map(ypids_with_ds, fn {ypid, _} -> {ypid, nil} end)
    loop(%State{ws: new_ws, xpids_with_vals: new_xpids_with_vals, ypids_with_ds: new_ypids_with_ds, a: a, status: :wait_xvals})
  end

  defp maybe_act(%State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, status: status} = state) do
    cond do
      Enum.count(xpids_with_vals) == length(ws) && (status == :wait_xpids || status == :wait_xvals) ->
        forward(state)
      Enum.all?(ypids_with_ds, fn {_, d} -> d != nil end) && status == :wait_dvals->
        backward(state)
      true -> nil
    end
  end

  defp loop(%State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a, status: status} = state) do
    maybe_act(state)
    receive do
      {:x, x, caller} ->
        new_xpids_with_vals = case Enum.any?(xpids_with_vals, fn {xpid, _} -> xpid == caller end) do
          true -> Utils.update_keyword_list(xpids_with_vals, caller, x)
          false -> [{caller, x} | xpids_with_vals]
        end
        loop(%State{ws: ws, xpids_with_vals: new_xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a, status: status})
      {:y, d, caller} ->
        new_ypids_with_ds = Utils.update_keyword_list(ypids_with_ds, caller, d)
        loop(%State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: new_ypids_with_ds, a: a, status: status})
    end
  end

end
