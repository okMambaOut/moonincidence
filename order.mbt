///|
/// Invalid inputs, arithmetic limits and resource exhaustion are explicit errors.
pub(all) suberror OrderError {
  InvalidSize(Int32)
  InvalidVertex(Int32)
  Cycle
  InvalidMatrix
  DuplicateVertex(Int32)
  InvalidSubset
  NotIdeal
  NotExtension
  IncompatibleOrders
  InvalidCoefficient(Int32, Int32)
  DimensionMismatch
  NonUnitDiagonal(Int32)
  ArithmeticOverflow
  InvalidBudget
  BudgetExceeded
  TooManyVertices(Int32)
  RankOutOfRange
} derive(Debug, Eq)

///|
/// Immutable finite partial order; indices always retain the caller's labels.
pub struct Poset {
  priv count : Int32
  priv relation : Array[Bool]
  priv linear : Array[Int32]
} derive(Debug, Eq)

///|
fn valid_size(n : Int32) -> Unit raise OrderError {
  if n < 0 || n > 256 {
    raise InvalidSize(n)
  }
}

///|
fn Poset::vertex(self : Poset, v : Int32) -> Unit raise OrderError {
  if v < 0 || v >= self.count {
    raise InvalidVertex(v)
  }
}

///|
fn Poset::rel(self : Poset, a : Int32, b : Int32) -> Bool {
  self.relation[a * self.count + b]
}

///|
fn order_from_closed(n : Int32, relation : Array[Bool]) -> Poset {
  let ranks = Array::make(n, 0)
  for x in 0..<n {
    for y in 0..<n {
      if relation[y * n + x] {
        ranks[x] += 1
      }
    }
  }
  let linear : Array[Int32] = []
  for v in 0..<n {
    let mut i = linear.length()
    linear.push(v)
    while i > 0 && ranks[linear[i - 1]] > ranks[v] {
      linear[i] = linear[i - 1]
      i -= 1
    }
    linear[i] = v
  }
  { count: n, relation, linear, }
}

///|
/// Build the reflexive transitive closure of strict constraints a < b.
/// Redundant edges are accepted; self edges and cycles are rejected.
pub fn Poset::from_relations(
  n : Int32,
  constraints : Array[(Int32, Int32)],
) -> Poset raise OrderError {
  valid_size(n)
  let relation = Array::make(n * n, false)
  for i in 0..<n {
    relation[i * n + i] = true
  }
  for edge in constraints {
    let (a, b) = edge
    if a < 0 || a >= n {
      raise InvalidVertex(a)
    }
    if b < 0 || b >= n {
      raise InvalidVertex(b)
    }
    if a == b {
      raise Cycle
    }
    relation[a * n + b] = true
  }
  for k in 0..<n {
    for i in 0..<n {
      if relation[i * n + k] {
        for j in 0..<n {
          if relation[k * n + j] {
            relation[i * n + j] = true
          }
        }
      }
    }
  }
  for i in 0..<n {
    for j in 0..<i {
      if relation[i * n + j] && relation[j * n + i] {
        raise Cycle
      }
    }
  }
  order_from_closed(n, relation)
}

///|
/// Import a complete reflexive order matrix, without silently repairing it.
pub fn Poset::from_matrix(
  matrix : Array[Array[Bool]],
) -> Poset raise OrderError {
  let n = matrix.length()
  valid_size(n)
  let relation = Array::make(n * n, false)
  for i in 0..<n {
    if matrix[i].length() != n || !matrix[i][i] {
      raise InvalidMatrix
    }
    for j in 0..<n {
      relation[i * n + j] = matrix[i][j]
    }
  }
  for i in 0..<n {
    for j in 0..<n {
      if i != j && relation[i * n + j] && relation[j * n + i] {
        raise InvalidMatrix
      }
      if relation[i * n + j] {
        for k in 0..<n {
          if relation[j * n + k] && !relation[i * n + k] {
            raise InvalidMatrix
          }
        }
      }
    }
  }
  order_from_closed(n, relation)
}

///|
pub fn Poset::size(self : Poset) -> Int32 {
  self.count
}

///|
pub fn Poset::leq(self : Poset, a : Int32, b : Int32) -> Bool raise OrderError {
  self.vertex(a)
  self.vertex(b)
  self.rel(a, b)
}

///|
/// Returns a defensive copy; changing the result cannot mutate this order.
pub fn Poset::matrix(self : Poset) -> Array[Array[Bool]] {
  Array::makei(self.count, fn(i) {
    Array::makei(self.count, fn(j) { self.rel(i, j) })
  })
}

///|
pub extend Poset with Eq::{equal, not_equal}

///|
pub extend OrderError with Eq::{equal, not_equal}

///|
pub extend Poset with @debug.Debug::{to_repr}

///|
pub extend OrderError with @debug.Debug::{to_repr}
