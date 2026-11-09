///|
fn Kernel::vector_size(
  self : Kernel,
  values : Array[Int64],
) -> Unit raise OrderError {
  if values.length() != self.order.count {
    raise DimensionMismatch
  }
}

///|
/// out[y] = sum(x<=y) kernel(x,y) * values[x].
pub fn Kernel::apply_lower(
  self : Kernel,
  values : Array[Int64],
) -> Array[Int64] raise OrderError {
  self.vector_size(values)
  let n = self.order.count
  let out = Array::make(n, 0L)
  for y in 0..<n {
    let mut sum = 0L
    for x in 0..<n {
      if self.order.rel(x, y) {
        sum = checked_add(
          sum,
          checked_mul(self.coefficients[x * n + y], values[x]),
        )
      }
    }
    out[y] = sum
  }
  out
}

///|
/// out[x] = sum(x<=y) kernel(x,y) * values[y].
pub fn Kernel::apply_upper(
  self : Kernel,
  values : Array[Int64],
) -> Array[Int64] raise OrderError {
  self.vector_size(values)
  let n = self.order.count
  let out = Array::make(n, 0L)
  for x in 0..<n {
    let mut sum = 0L
    for y in 0..<n {
      if self.order.rel(x, y) {
        sum = checked_add(
          sum,
          checked_mul(self.coefficients[x * n + y], values[y]),
        )
      }
    }
    out[x] = sum
  }
  out
}

///|
/// Recover v from apply_lower(v), by forward substitution over the partial order.
pub fn Kernel::solve_lower(
  self : Kernel,
  totals : Array[Int64],
) -> Array[Int64] raise OrderError {
  self.vector_size(totals)
  let n = self.order.count
  let out = Array::make(n, 0L)
  for y in self.order.linear {
    let diagonal = self.coefficients[y * n + y]
    if diagonal != 1L && diagonal != -1L {
      raise NonUnitDiagonal(y)
    }
    let mut remainder = totals[y]
    for x in 0..<n {
      if x != y && self.order.rel(x, y) {
        remainder = checked_sub(
          remainder,
          checked_mul(self.coefficients[x * n + y], out[x]),
        )
      }
    }
    out[y] = if diagonal == 1L { remainder } else { checked_neg(remainder) }
  }
  out
}

///|
/// Recover v from apply_upper(v), by reverse substitution.
pub fn Kernel::solve_upper(
  self : Kernel,
  totals : Array[Int64],
) -> Array[Int64] raise OrderError {
  self.vector_size(totals)
  let n = self.order.count
  let out = Array::make(n, 0L)
  for offset in 0..<n {
    let x = self.order.linear[n - 1 - offset]
    let diagonal = self.coefficients[x * n + x]
    if diagonal != 1L && diagonal != -1L {
      raise NonUnitDiagonal(x)
    }
    let mut remainder = totals[x]
    for y in 0..<n {
      if x != y && self.order.rel(x, y) {
        remainder = checked_sub(
          remainder,
          checked_mul(self.coefficients[x * n + y], out[y]),
        )
      }
    }
    out[x] = if diagonal == 1L { remainder } else { checked_neg(remainder) }
  }
  out
}
