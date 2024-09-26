import minigen

pub fn seed() -> Int {
  1_000_000 + 1
  |> minigen.integer
  |> minigen.run
}
