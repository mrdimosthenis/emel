import gleam/dict.{type Dict}

pub fn unsafe_res(res: Result(a, _)) -> a {
  let assert Ok(r) = res
  r
}

pub fn unsafe_f(f: fn(a) -> Result(b, _)) -> fn(a) -> b {
  fn(x) {
    let assert Ok(res) = f(x)
    res
  }
}

pub fn unsafe_get(m: Dict(a, b), k: a) -> b {
  m
  |> dict.get(k)
  |> unsafe_res
}
