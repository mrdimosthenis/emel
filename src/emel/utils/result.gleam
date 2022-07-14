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
