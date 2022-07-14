import emel/utils/min_sorted_zlist as mszl
import gleam/option.{None, Some}
import gleam_zlists as zlist
import gleeunit/should

pub fn new_test() {
  3
  |> mszl.new
  |> zlist.to_list
  |> should.equal([None, None, None])

  1
  |> mszl.new
  |> zlist.to_list
  |> should.equal([None])

  0
  |> mszl.new
  |> zlist.to_list
  |> should.equal([])
}

pub fn updated_test() {
  let mszl1 = mszl.new(3)

  let mszl2 = mszl.updated(mszl1, #("one", 1.0))

  mszl2
  |> zlist.to_list
  |> should.equal([Some(#("one", 1.0)), None, None])

  let mszl3 = mszl.updated(mszl2, #("two", 2.0))

  mszl3
  |> zlist.to_list
  |> should.equal([Some(#("one", 1.0)), Some(#("two", 2.0)), None])

  let mszl4 = mszl.updated(mszl3, #("half", 0.5))

  mszl4
  |> zlist.to_list
  |> should.equal([
    Some(#("half", 0.5)),
    Some(#("one", 1.0)),
    Some(#("two", 2.0)),
  ])

  let mszl5 = mszl.updated(mszl4, #("zero", 0.0))

  mszl5
  |> zlist.to_list
  |> should.equal([
    Some(#("zero", 0.0)),
    Some(#("half", 0.5)),
    Some(#("one", 1.0)),
  ])

  let mszl6 = mszl.updated(mszl5, #("another half", 0.5))

  mszl6
  |> zlist.to_list
  |> should.equal([
    Some(#("zero", 0.0)),
    Some(#("another half", 0.5)),
    Some(#("half", 0.5)),
  ])

  let mszl7 = mszl.updated(mszl6, #("yet another half", 0.5))

  mszl7
  |> zlist.to_list
  |> should.equal([
    Some(#("zero", 0.0)),
    Some(#("yet another half", 0.5)),
    Some(#("another half", 0.5)),
  ])

  let mszl8 = mszl.updated(mszl7, #("minus one", -1.0))

  mszl8
  |> zlist.to_list
  |> should.equal([
    Some(#("minus one", -1.0)),
    Some(#("zero", 0.0)),
    Some(#("yet another half", 0.5)),
  ])
}

pub fn extract_test() {
  [
    Some(#("yet another two", 2.0)),
    Some(#("another two", 2.0)),
    Some(#("three", 3.0)),
  ]
  |> zlist.of_list
  |> mszl.extract
  |> zlist.to_list
  |> should.equal(["yet another two", "another two", "three"])

  [Some(#("one", 1.0)), None, None]
  |> zlist.of_list
  |> mszl.extract
  |> zlist.to_list
  |> should.equal(["one"])

  [None, None, None]
  |> zlist.of_list
  |> mszl.extract
  |> zlist.to_list
  |> should.equal([])
}
