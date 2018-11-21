defmodule Ml.Net.FitNeuron do
  @moduledoc false

  alias Help.Utils
  alias Math.Geometry
  alias Math.Calculus

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:ws, :xpids_with_vals, :ypids_with_ds, :a, :status]
  end

  # Client

  def start_link(default)  do
    GenServer.start_link(__MODULE__, default)
  end

  def fire(pid, xpid, xval) do
    GenServer.cast(pid, {:fire, xpid, xval})
  end

  def back_propagate(pid, ypid, dval) do
    GenServer.cast(pid, {:back_propagate, ypid, dval})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true
  def init([n_or_ws, a, ypids]) do
    ws = if is_number(n_or_ws) do
      Utils.rand_float(n_or_ws)
    else
      n_or_ws
    end
    xpids_with_vals = []
    ypids_with_ds = Enum.zip(ypids, Stream.cycle([nil]))
    state = %State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a, status: :wait_xvals}
    {:ok, state}
  end

  @impl true
  def handle_cast(
        {:fire, xpid, xval},
        %State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, status: status} = state
      ) do
    new_xpids_with_vals = Utils.put_into_keylist(xpids_with_vals, xpid, xval)
    new_status = if Enum.count(new_xpids_with_vals) == length(ws) &&
                      Enum.all?(new_xpids_with_vals, fn {_, x} -> x != nil end) &&
                      status == :wait_xvals do
      y = new_xpids_with_vals
          |> Enum.map(fn {_, x} -> x end)
          |> Geometry.dot_product(ws)
          |> Calculus.logistic_function()
      Enum.each(ypids_with_ds, fn {ypid, _} -> fire(ypid, self(), y) end)
      :wait_dvals
    else
      status
    end
    {:noreply, %{state | xpids_with_vals: new_xpids_with_vals, status: new_status}}
  end
  def handle_cast(
        {:back_propagate, ypid, dval},
        %State{ws: ws, xpids_with_vals: xpids_with_vals, ypids_with_ds: ypids_with_ds, a: a, status: status} = state
      ) do
    new_ypids_with_ds = Utils.put_into_keylist(ypids_with_ds, ypid, dval)
    new_state = if Enum.all?(new_ypids_with_ds, fn {_, d} -> d != nil end) && status == :wait_dvals do
      theta = xpids_with_vals
              |> Enum.map(fn {_, x} -> x end)
              |> Geometry.dot_product(ws)
      delta = new_ypids_with_ds
              |> Enum.map(fn {_, d} -> d end)
              |> Enum.sum()
      common_factor = delta * Calculus.logistic_derivative(theta)
      xpids_with_vals
      |> Enum.map(fn {xpid, _} -> xpid end)
      |> Enum.zip(ws)
      |> Enum.each(fn {xpid, w} -> back_propagate(xpid, self(), common_factor * w) end)
      new_ws = xpids_with_vals
               |> Enum.map(fn {_, x} -> x end)
               |> Enum.zip(ws)
               |> Enum.map(fn {x, w} -> w - a * common_factor * x end)
      new_xpids_with_vals = Enum.map(xpids_with_vals, fn {xpid, _} -> {xpid, nil} end)
      cleared_ypids_with_ds = Enum.map(new_ypids_with_ds, fn {ypid, _} -> {ypid, nil} end)
      %State{
        ws: new_ws,
        xpids_with_vals: new_xpids_with_vals,
        ypids_with_ds: cleared_ypids_with_ds,
        a: a,
        status: :wait_xvals
      }
    else
      %{state | ypids_with_ds: new_ypids_with_ds}
    end
    {:noreply, new_state}
  end

end
