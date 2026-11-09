///|
/// Total order 0 < 1 < ... < n-1.
pub fn Poset::chain(n : Int32) -> Poset raise OrderError {
  valid_size(n)
  order_from_closed(n, Array::makei(n * n, fn(k) { k / n <= k % n }))
}

///|
pub fn Poset::antichain(n : Int32) -> Poset raise OrderError {
  valid_size(n)
  order_from_closed(n, Array::makei(n * n, fn(k) { k / n == k % n }))
}

///|
/// Subset order on bit masks 0..2^dimension-1. At most 8 dimensions.
pub fn Poset::boolean_lattice(dimension : Int32) -> Poset raise OrderError {
  if dimension < 0 || dimension > 8 {
    raise InvalidSize(dimension)
  }
  let n = 1 << dimension
  let relation = Array::makei(n * n, fn(k) {
    let a = k / n
    let b = k % n
    (a & b) == a
  })
  order_from_closed(n, relation)
}

///|
/// Divisibility order of distinct positive integers, preserving input indices.
/// The supplied set need not include every divisor.
pub fn Poset::divisibility(values : Array[Int32]) -> Poset raise OrderError {
  let n = values.length()
  valid_size(n)
  for i in 0..<n {
    if values[i] <= 0 {
      raise InvalidSubset
    }
    for j in 0..<i {
      if values[i] == values[j] {
        raise DuplicateVertex(i)
      }
    }
  }
  let relation = Array::makei(n * n, fn(k) {
    values[k % n] % values[k / n] == 0
  })
  order_from_closed(n, relation)
}
