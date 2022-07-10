import gleam_zlists.{ZList} as zlist

pub fn dot_product(x: ZList(Float), y: ZList(Float)) -> Float {
  zlist.zip(x, y)
  |> zlist.map(fn(t) {
    let #(a, b) = t
    a *. b
  })
  |> zlist.sum
}
