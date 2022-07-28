import minigen

pub fn seed() -> Int {
  1000000 + 1
  |> minigen.integer
  |> minigen.run
}
