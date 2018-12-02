defmodule Ml.NeuralNetwork do
  @moduledoc """
  A collection of connected neurons, that looks like a biological brain.
  Each connection, can transmit a signal from one neuron to another.

  """

  alias Help.Utils
  alias Math.Statistics
  alias Ml.Net.FitWrapper
  alias Ml.Net.Wrapper

  defp iterate(_, _, _, _, _, 0), do: nil
  defp iterate(fit_wrapper, xs, ys, a, err_thres, max_iter) do
    Enum.zip(xs, ys)
    |> Enum.each(fn {x, y} -> FitWrapper.fit(fit_wrapper, x, y) end)
    weights = FitWrapper.get_weights(fit_wrapper)
    mean_abs_err = Wrapper.with(
      [weights, 1],
      fn wrapper ->
        mean_absolute_errors = xs
                               |> Enum.map(
                                    fn x ->
                                      Wrapper.predict(wrapper, x)
                                    end
                                  )
                               |> Enum.zip(ys)
                               |> Enum.map(
                                    fn {y_hat_list, y_list} ->
                                      Statistics.mean_absolute_error(y_hat_list, y_list)
                                    end
                                  )
        mean_absolute_errors / length(ys)
      end
    )
    case mean_abs_err < err_thres do
      true -> nil
      false -> iterate(fit_wrapper, xs, ys, a, err_thres, max_iter - 1)
    end
  end

  defp predict(item, wrapper, continuous_attributes, dist_class_vals) do
    f = fn x -> Wrapper.predict(wrapper, x) end
    {_, selected_class} = item
                          |> Utils.map_vals(continuous_attributes)
                          |> f.()
                          |> Enum.zip(dist_class_vals)
                          |> Enum.max_by(fn {y_hat, _} -> y_hat end)
    selected_class
  end

  def classifier(
        dataset,
        continuous_attributes,
        class,
        hidden_layers,
        learning_rate \\ 0.0001,
        err_thres \\ 0.1,
        max_iter \\ 10000
      ) do
    [x | _] = xs = Enum.map(dataset, fn row -> Utils.map_vals(row, continuous_attributes) end)
    dist_class_vals = dataset
                      |> Enum.map(fn row -> row[class] end)
                      |> Enum.uniq()
    ys = Enum.map(
      dataset,
      fn row ->
        selected_index = Enum.find_index(dist_class_vals, fn class_val -> class_val == row[class] end)
        for i <- Utils.indices(dist_class_vals) do
          case i do
            ^selected_index -> 1.0
            _ -> 0.0
          end
        end
      end
    )
    weights = FitWrapper.with(
      [length(x), length(dist_class_vals), hidden_layers, learning_rate],
      fn fit_wrapper ->
        iterate(fit_wrapper, xs, ys, learning_rate, err_thres, max_iter)
        FitWrapper.get_weights(fit_wrapper)
      end
    )
    fn
      %{} = item ->
        Wrapper.with(
          [weights, length(dist_class_vals)],
          fn wrapper -> predict(item, wrapper, continuous_attributes, dist_class_vals) end
        )
      [_ | _] = items ->
        Wrapper.with(
          [weights, length(dist_class_vals)],
          fn wrapper ->
            Enum.map(items, fn x -> predict(x, wrapper, continuous_attributes, dist_class_vals) end)
          end
        )
    end
  end

end
