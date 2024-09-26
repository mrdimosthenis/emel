import emel/lazy/math/statistics
import emel/utils/result as ut_res
import emel/utils/zlist as ut_zlist
import gleam/dict
import gleam_synapses/codec.{type Codec}
import gleam_synapses/model/net_elems/network/network.{type Network}
import gleam_synapses/model/net_elems/network/network_serialized
import gleam_zlists.{type ZList} as zlist
import minigen

fn mean_absolute_error(
  outputs: ZList(ZList(Float)),
  expected_outputs: ZList(ZList(Float)),
) -> Float {
  let #(numerator, denominator) =
    zlist.reduce(zlist.zip(outputs, expected_outputs), #(0.0, 0.0), fn(p, acc) {
      let #(predictions, observations) = p
      let #(numer, denom) = acc
      let next_numer =
        numer +. statistics.mean_absolute_error(predictions, observations)
      let next_denom = denom +. 1.0
      #(next_numer, next_denom)
    })
  numerator /. denominator
}

fn initial_network(
  hidden_layers: ZList(Int),
  inputs: ZList(ZList(Float)),
  class_vals: ZList(String),
  seed: Int,
) -> Network {
  let input_layer_size =
    inputs
    |> zlist.head
    |> ut_res.unsafe_res
    |> zlist.count
  let output_layer_size =
    class_vals
    |> ut_zlist.uniq
    |> zlist.count
  [
    zlist.singleton(input_layer_size),
    hidden_layers,
    zlist.singleton(output_layer_size),
  ]
  |> zlist.of_list
  |> zlist.concat
  |> network.generator
  |> minigen.run_with_seed(seed)
  |> network_serialized.realized
}

pub fn iterate(
  net: Network,
  learning_rate: Float,
  inputs: ZList(ZList(Float)),
  expected_outputs: ZList(ZList(Float)),
  error_threshold: Float,
  countdown: Int,
) -> Network {
  case countdown {
    0 -> net
    _ -> {
      let next_net =
        zlist.zip(inputs, expected_outputs)
        |> zlist.reduce(net, fn(t, acc) {
          let #(xs, ys) = t
          network.fit(acc, learning_rate, xs, ys, False)
          |> network_serialized.realized
        })
      let mean_abs_err =
        inputs
        |> zlist.map(network.output(next_net, _, False))
        |> mean_absolute_error(expected_outputs)
      case mean_abs_err <. error_threshold {
        True -> next_net
        False ->
          iterate(
            next_net,
            learning_rate,
            inputs,
            expected_outputs,
            error_threshold,
            countdown - 1,
          )
      }
    }
  }
}

pub fn classifier(
  dataset: ZList(#(ZList(Float), String)),
  hidden_layers: ZList(Int),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
  seed: Int,
) -> fn(ZList(Float)) -> String {
  let #(inputs, class_vals) = zlist.unzip(dataset)
  let cdc: Codec =
    class_vals
    |> zlist.map(fn(c) { dict.from_list([#("class", c)]) })
    |> zlist.to_iterator
    |> codec.new([#("class", True)], _)
  let expected_outputs =
    class_vals
    |> zlist.map(fn(c) {
      [#("class", c)]
      |> dict.from_list
      |> codec.encode(cdc, _)
    })
    |> zlist.map(zlist.of_list)
  let net: Network =
    initial_network(hidden_layers, inputs, class_vals, seed)
    |> iterate(
      learning_rate,
      inputs,
      expected_outputs,
      error_threshold,
      max_iterations,
    )
  fn(xs) {
    xs
    |> network.output(net, _, False)
    |> zlist.to_list
    |> codec.decode(cdc, _)
    |> ut_res.unsafe_get("class")
  }
}
