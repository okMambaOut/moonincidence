///|
/// An immutable integer coefficient for every interval of one finite order.
#derive(Debug, Eq)
pub struct Kernel {
  priv order : Poset
  priv coefficients : Array[Int64]
}

///|
pub extend Kernel with Eq::{equal, not_equal}

///|
pub extend Kernel with @debug.Debug::{to_repr}

///|
pub fn Kernel::zero(order : Poset) -> Kernel {
  { order, coefficients: Array::make(order.count * order.count, 0L), }
}

///|
pub fn Kernel::delta(order : Poset) -> Kernel {
  let n = order.count
  let coefficients = Array::make(n * n, 0L)
  for i in 0..<n {
    coefficients[i * n + i] = 1L
  }
  { order, coefficients, }
}

///|
pub fn Kernel::zeta(order : Poset) -> Kernel {
  {
    order,
    coefficients: order.relation.map(fn(b) { if b { 1L } else { 0L } }),
  }
}

///|
/// Missing intervals are zero. Duplicate entries and non-intervals are errors.
pub fn Kernel::from_entries(
  order : Poset,
  entries : Array[(Int32, Int32, Int64)],
) -> Kernel raise OrderError {
  let out = Kernel::zero(order)
  let seen = Array::make(order.count * order.count, false)
  for entry in entries {
    let (a, b, value) = entry
    order.vertex(a)
    order.vertex(b)
    let k = a * order.count + b
    if !order.rel(a, b) || seen[k] {
      raise InvalidCoefficient(a, b)
    }
    seen[k] = true
    out.coefficients[k] = value
  }
  out
}

///|
/// Dense import rejects nonzero coefficients outside the incidence relation.
pub fn Kernel::from_matrix(
  order : Poset,
  matrix : Array[Array[Int64]],
) -> Kernel raise OrderError {
  let n = order.count
  if matrix.length() != n {
    raise DimensionMismatch
  }
  let coefficients = Array::make(n * n, 0L)
  for x in 0..<n {
    if matrix[x].length() != n {
      raise DimensionMismatch
    }
    for y in 0..<n {
      if matrix[x][y] != 0L && !order.rel(x, y) {
        raise InvalidCoefficient(x, y)
      }
      coefficients[x * n + y] = matrix[x][y]
    }
  }
  { order, coefficients, }
}

///|
pub fn Kernel::poset(self : Kernel) -> Poset {
  self.order
}

///|
/// Incomparable endpoints have coefficient zero, not an interval error.
pub fn Kernel::coefficient(
  self : Kernel,
  a : Int32,
  b : Int32,
) -> Int64 raise OrderError {
  self.order.vertex(a)
  self.order.vertex(b)
  self.coefficients[a * self.order.count + b]
}

///|
pub fn Kernel::matrix(self : Kernel) -> Array[Array[Int64]] {
  let n = self.order.count
  Array::makei(n, fn(i) {
    Array::makei(n, fn(j) { self.coefficients[i * n + j] })
  })
}

///|
/// Functional update; neither this kernel nor input matrices are aliased.
pub fn Kernel::with_coefficient(
  self : Kernel,
  a : Int32,
  b : Int32,
  value : Int64,
) -> Kernel raise OrderError {
  self.order.vertex(a)
  self.order.vertex(b)
  if !self.order.rel(a, b) {
    raise InvalidCoefficient(a, b)
  }
  let coefficients = self.coefficients.copy()
  coefficients[a * self.order.count + b] = value
  { order: self.order, coefficients, }
}

///|
fn Kernel::compatible(self : Kernel, other : Kernel) -> Unit raise OrderError {
  if self.order != other.order {
    raise IncompatibleOrders
  }
}

///|
pub fn Kernel::add(self : Kernel, other : Kernel) -> Kernel raise OrderError {
  self.compatible(other)
  let coefficients = Array::make(self.coefficients.length(), 0L)
  for i in 0..<coefficients.length() {
    coefficients[i] = checked_add(self.coefficients[i], other.coefficients[i])
  }
  { order: self.order, coefficients, }
}

///|
pub fn Kernel::subtract(
  self : Kernel,
  other : Kernel,
) -> Kernel raise OrderError {
  self.compatible(other)
  let coefficients = Array::make(self.coefficients.length(), 0L)
  for i in 0..<coefficients.length() {
    coefficients[i] = checked_sub(self.coefficients[i], other.coefficients[i])
  }
  { order: self.order, coefficients, }
}

///|
pub fn Kernel::scale(self : Kernel, factor : Int64) -> Kernel raise OrderError {
  let coefficients = Array::make(self.coefficients.length(), 0L)
  for i in 0..<coefficients.length() {
    coefficients[i] = checked_mul(self.coefficients[i], factor)
  }
  { order: self.order, coefficients, }
}
