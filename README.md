# emel

Turn data into functions! A simple and functional **machine learning** library, implemented in **Gleam** for the **Erlang** ecosystem.

## Installation

* For **Erlang** projects, add the dependency into `rebar.config`:

```erlang
{deps, [
    {emel, "1.0.0-rc2"}
]}.
```

* For **Elixir** projects, add the dependency into `mix.exs`:

```elixir
defp deps do
  [
    {:emel, "~> 1.0.0-rc2"}
  ]
end
```

* For **Gleam** projects, run `gleam add emel`.

## Examples

### Erlang

```erlang
Data = [
  {[7.0, 7.0], "bad"},
  {[7.0, 4.0], "bad"},
  {[3.0, 4.0], "good"},
  {[1.0, 4.0], "good"}
],
F = emel@ml@k_nearest_neighbors:classifier(Data, 3),
F([3.0, 7.0]). % "good"
```
 
### Elixir

```elixir
data = [
  {[1.794638, 15.15426], 0.510998918},
  {[3.220726, 229.6516], 105.6583692},
  {[5.780040, 3480.201], 1776.99}
]
f = :emel@ml@linear_regression_test.predictor(data)
f.([3.0, 230.0]) # 106.74114058686602
```

### Gleam

```gleam
import emel/ml/neural_network as nn
let data = [
  #([0.8, 0.0, 0.0], "x"),
  #([0.0, 0.9, 0.0], "y"),
  #([0.0, 0.0, 0.8], "z"),
]
let f = nn.classifier(
    data,
    [4],           // hidden layers
    0.01,          // learning rate
    0.1,           // error threshold
    1000           // maximum iterations
)
f([0.0, 0.8, 0.0]) // "y"
```

## Documentation

The [documentation](https://hexdocs.pm/emel/1.0.0-rc2) describes all the public functions. **Gleam** developers can pay attention to the type annotations. **Erlang** and **Elixir** devs may take a look at the examples which are written in **Erlang**.

### Implemented Algorithms

 * [Linear Regression](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/linear_regression.html)
 * [K Nearest Neighbors](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/k_nearest_neighbors.html)
 * [Decision Tree](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/decision_tree.html)
 * [Naive Bayes](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/naive_bayes.html)
 * [K Means](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/k_means.html)
 * [Perceptron](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/perceptron.html)
 * [Logistic Regression](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/logistic_regression.html)
 * [Neural Network](https://hexdocs.pm/emel/1.0.0-rc2/emel/ml/neural_network.html)

### Mathematics

* [Algebra](https://hexdocs.pm/emel/1.0.0-rc2/emel/math/algebra.html)
* [Geometry](https://hexdocs.pm/emel/1.0.0-rc2/emel/math/geometry.html)
* [Statistics](https://hexdocs.pm/emel/1.0.0-rc2/emel/math/statistics.html)

_For the documentation of the previous version (`0.3.0`), click [here](https://hexdocs.pm/emel/0.3.0)._
