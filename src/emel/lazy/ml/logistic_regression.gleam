import emel/lazy/ml/neural_network as nn
import emel/utils/result as ut_res
import gleam_synapses/model/net_elems/network/network.{type Network}
import gleam_synapses/model/net_elems/network/network_serialized
import gleam_zlists.{type ZList} as zlist
import minigen

fn initial_network(inputs: ZList(ZList(Float)), seed: Int) -> Network {
  inputs
  |> zlist.head
  |> ut_res.unsafe_res
  |> zlist.count
  |> zlist.singleton
  |> zlist.append(zlist.singleton(1))
  |> network.generator
  |> minigen.run_with_seed(seed)
  |> network_serialized.realized
}

pub fn classifier(
  dataset: ZList(#(ZList(Float), Bool)),
  learning_rate: Float,
  error_threshold: Float,
  max_iterations: Int,
  seed: Int,
) -> fn(ZList(Float)) -> Bool {
  let #(inputs, class_vals) = zlist.unzip(dataset)
  let expected_outputs =
    class_vals
    |> zlist.map(fn(c) {
      case c {
        True -> [1.0]
        False -> [0.0]
      }
    })
    |> zlist.map(zlist.of_list)
  let net: Network =
    initial_network(inputs, seed)
    |> nn.iterate(
      learning_rate,
      inputs,
      expected_outputs,
      error_threshold,
      max_iterations,
    )
  fn(xs) {
    let y_hat =
      xs
      |> network.output(net, _, False)
      |> zlist.head
      |> ut_res.unsafe_res
    y_hat >=. 0.5
  }
}
