import gleam/map.{Map}

pub fn unsafe_res(res: Result(a, _)) -> a {
  assert Ok(r) = res
  r
}

pub fn unsafe_f(f: fn(a) -> Result(b, _)) -> fn(a) -> b {
  fn(x) {
    assert Ok(res) = f(x)
    res
  }
}

pub fn unsafe_get(m: Map(a, b), k: a) -> b {
  m
  |> map.get(k)
  |> unsafe_res
}
