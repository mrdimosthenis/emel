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

  defp predict(item, wrapper, continuous_attributes) do
    f = fn x -> Wrapper.predict(wrapper, x) end
    y_hat = item
            |> Utils.map_vals(continuous_attributes)
            |> f.()
            |> hd
    y_hat >= 0.5
  end

  @doc """
  Returns the function that classifies an item (or a list of items) by using the _Logistic Regression Algorithm_.

  ## Examples

      iex> f = Ml.LogisticRegression.classifier([%{a: 0, b: 0, and: false},
      ...>                                       %{a: 0, b: 1, and: false},
      ...>                                       %{a: 1, b: 0, and: false},
      ...>                                       %{a: 1, b: 1, and: true},
      ...>                                      ], [:a, :b], :and, 0.5, 0.001, 100)
      ...> f.(%{a: 1, b: 1})
      true

      iex> f = Ml.LogisticRegression.classifier([%{x: 0.0, y: 0.1, greater_than: false},
      ...>                                       %{x: 0.3, y: 0.2, greater_than: true},
      ...>                                       %{x: 0.2, y: 0.3, greater_than: false},
      ...>                                       %{x: 0.3, y: 0.4, greater_than: false},
      ...>                                       %{x: 0.4, y: 0.3, greater_than: true},
      ...>                                       %{x: 0.5, y: 0.5, greater_than: false},
      ...>                                       %{x: 0.5, y: 0.6, greater_than: false},
      ...>                                       %{x: 0.1, y: 0.2, greater_than: false},
      ...>                                       %{x: 0.0, y: 0.0, greater_than: false},
      ...>                                       %{x: 0.1, y: 0.0, greater_than: true},
      ...>                                       %{x: 0.2, y: 0.1, greater_than: true},
      ...>                                       %{x: 0.6, y: 0.7, greater_than: false},
      ...>                                      ], [:x, :y], :greater_than, 0.1, 0.01, 1000)
      ...> f.([%{x: 0.2, y: 0.1},
      ...>     %{x: 0.3, y: 0.2},
      ...>     %{x: 0.1, y: 0.3},
      ...>     %{x: 0.3, y: 0.1},
      ...>     %{x: 0.5, y: 0.4},
      ...>     %{x: 0.5, y: 0.5}])
      [true, true, false, true, true, false]

  """
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
    fn
      %{} = item ->
        {:ok, wrapper} = GenServer.start_link(Wrapper, [weights, 1])
        result = predict(item, wrapper, continuous_attributes)
        Wrapper.stop(wrapper)
        result
      [_ | _] = items ->
        {:ok, wrapper} = GenServer.start_link(Wrapper, [weights, 1])
        results = Enum.map(items, fn x -> predict(x, wrapper, continuous_attributes) end)
        Wrapper.stop(wrapper)
        results
    end
  end

end
