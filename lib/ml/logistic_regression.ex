defmodule Ml.LogisticRegression do
  @moduledoc """
  A classification algorithm used to assign observations to a set of two classes.
  It transforms its output using the _logistic sigmoid function_ to return a probability value
  which can then be mapped to the classes.

  """

  alias Help.Utils
  alias Math.Statistics
  alias Ml.Net.FitWrapper
  alias Ml.Net.Wrapper

  defp iterate(_, _, _, _, _, 0), do: nil
  defp iterate(fit_wrapper, xs, ys, a, err_thres, max_iter) do
    Enum.zip(xs, ys)
    |> Enum.each(fn {x, y} -> FitWrapper.fit(fit_wrapper, x, [y]) end)
    weights = FitWrapper.get_weights(fit_wrapper)
    {:ok, wrapper} = GenServer.start_link(Wrapper, [weights, 1])
    mean_abs_err = xs
                   |> Enum.map(
                        fn x ->
                          [y_hat] = Wrapper.predict(wrapper, x)
                          y_hat
                        end
                      )
                   |> Statistics.mean_absolute_error(ys)
    Wrapper.stop(wrapper)
    case mean_abs_err < err_thres do
      true -> nil
      false -> iterate(fit_wrapper, xs, ys, a, err_thres, max_iter - 1)
    end
  end

  def classifier(
        dataset,
        continuous_attributes,
        boolean_class,
        learning_rate \\ 0.0001,
        err_thres \\ 0.1,
        max_iter \\ 10000
      ) do
    [x | _] = xs = Enum.map(dataset, fn row -> Utils.map_vals(row, continuous_attributes) end)
    ys = Enum.map(
      dataset,
      fn row -> case row[boolean_class] do
                  true -> 1
                  false -> 0
                end
      end
    )
    {:ok, fit_wrapper} = GenServer.start_link(FitWrapper, [length(x), 1, [1], learning_rate])
    iterate(fit_wrapper, xs, ys, learning_rate, err_thres, max_iter)
    weights = FitWrapper.get_weights(fit_wrapper)
    FitWrapper.stop(fit_wrapper)
    fn item ->
      {:ok, wrapper} = GenServer.start_link(Wrapper, [weights, 1])
      item_vals = Utils.map_vals(item, continuous_attributes)
      [yhat] = Wrapper.predict(wrapper, item_vals)
      result = yhat >= 0.5
      Wrapper.stop(wrapper)
      result
    end
  end

end
