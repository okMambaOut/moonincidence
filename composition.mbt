///|
/// Independent union; right-hand indices are shifted by self.size().
pub fn Poset::disjoint_sum(
  self : Poset,
  other : Poset,
) -> Poset raise OrderError {
  let a = self.count
  let n = a + other.count
  valid_size(n)
  let relation = Array::make(n * n, false)
  for x in 0..<n {
    for y in 0..<n {
      relation[x * n + y] = if x < a && y < a {
        self.rel(x, y)
      } else if x >= a && y >= a {
        other.rel(x - a, y - a)
      } else {
        false
      }
    }
  }
  order_from_closed(n, relation)
}

///|
/// Ordered concatenation, placing every left element below every right one.
pub fn Poset::ordinal_sum(
  self : Poset,
  other : Poset,
) -> Poset raise OrderError {
  let union = self.disjoint_sum(other)
  let a = self.count
  let n = union.count
  let relation = union.relation.copy()
  for x in 0..<a {
    for y in a..<n {
      relation[x * n + y] = true
    }
  }
  order_from_closed(n, relation)
}

///|
/// Cartesian product: pair (x,y) has index x * other.size() + y.
pub fn Poset::product(self : Poset, other : Poset) -> Poset raise OrderError {
  let b = other.count
  let n = self.count * b
  valid_size(n)
  let relation = Array::make(n * n, false)
  for x in 0..<n {
    for y in 0..<n {
      relation[x * n + y] = self.rel(x / b, y / b) && other.rel(x % b, y % b)
    }
  }
  order_from_closed(n, relation)
}

///|
/// Add a fresh bottom (index 0) and top (last index).
pub fn Poset::bounded(self : Poset) -> Poset raise OrderError {
  let one = Poset::from_relations(1, [])
  one.ordinal_sum(self).ordinal_sum(one)
}
