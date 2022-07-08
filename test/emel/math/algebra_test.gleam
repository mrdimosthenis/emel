import emel/math/algebra
import gleeunit/should

pub fn first_minor_test() {
  [[1.0, 4.0, 7.0], [3.0, 0.0, 5.0], [-1.0, 9.0, 11.0]]
  |> algebra.first_minor(1, 2)
  |> should.equal([[1.0, 4.0], [-1.0, 9.0]])

  [[6.0, 1.0, 1.0], [4.0, -2.0, 5.0], [2.0, 8.0, 7.0]]
  |> algebra.first_minor(0, 0)
  |> should.equal([[-2.0, 5.0], [8.0, 7.0]])

  [
    [5.0, -7.0, 2.0, 2.0],
    [0.0, 3.0, 0.0, -4.0],
    [-5.0, -8.0, 0.0, 3.0],
    [0.0, 5.0, 0.0, -6.0],
  ]
  |> algebra.first_minor(0, 2)
  |> should.equal([[0.0, 3.0, -4.0], [-5.0, -8.0, 3.0], [0.0, 5.0, -6.0]])
}

pub fn determinant_test() {
  [[3.0, 8.0], [4.0, 6.0]]
  |> algebra.determinant
  |> should.equal(-14.0)

  [[6.0, 1.0, 1.0], [4.0, -2.0, 5.0], [2.0, 8.0, 7.0]]
  |> algebra.determinant
  |> should.equal(-306.0)

  [
    [4.0, 3.0, 2.0, 2.0],
    [0.0, 1.0, -3.0, 3.0],
    [0.0, -1.0, 3.0, 3.0],
    [0.0, 3.0, 1.0, 1.0],
  ]
  |> algebra.determinant
  |> should.equal(-240.0)
}

pub fn transpose_test() {
  [[1.0, 4.0], [3.0, 0.0]]
  |> algebra.transpose
  |> should.equal([[1.0, 3.0], [4.0, 0.0]])

  [[6.0, 1.0, 1.0], [4.0, -2.0, 5.0], [2.0, 8.0, 7.0]]
  |> algebra.transpose
  |> should.equal([[6.0, 4.0, 2.0], [1.0, -2.0, 8.0], [1.0, 5.0, 7.0]])
}

pub fn cramer_solution_test() {
  algebra.cramer_solution([[2.0, 3.0], [4.0, 9.0]], [6.0, 15.0])
  |> should.equal(Ok([1.5, 1.0]))

  algebra.cramer_solution(
    [[1.0, 3.0, -2.0], [3.0, 5.0, 6.0], [2.0, 4.0, 3.0]],
    [5.0, 7.0, 8.0],
  )
  |> should.equal(Ok([-15.0, 8.0, 2.0]))

  algebra.cramer_solution([[0.0, 0.0], [3.0, 5.0]], [0.0, 12.0])
  |> should.equal(Error("No unique solution"))
}
