///|
/// The inverse over Z exists exactly when every diagonal entry is +1 or -1.
/// Intermediate overflow is reported even if later cancellation would fit.
pub fn Kernel::inverse(self : Kernel) -> Kernel raise OrderError {
  let p = self.order
  let n = p.count
  for x in 0..<n {
    let value = self.coefficients[x * n + x]
    if value != 1L && value != -1L {
      raise NonUnitDiagonal(x)
    }
  }
  let coefficients = Array::make(n * n, 0L)
  for y in p.linear {
    for offset in 0..<n {
      let x = p.linear[n - 1 - offset]
      if x == y {
        coefficients[x * n + y] = self.coefficients[x * n + x]
      } else if p.rel(x, y) {
        let mut sum = 0L
        for z in 0..<n {
          if z != x && p.rel(x, z) && p.rel(z, y) {
            sum = checked_add(
              sum,
              checked_mul(self.coefficients[x * n + z], coefficients[z * n + y]),
            )
          }
        }
        coefficients[x * n + y] = if self.coefficients[x * n + x] == 1L {
          checked_neg(sum)
        } else {
          sum
        }
      }
    }
  }
  { order: p, coefficients, }
}

///|
pub fn Kernel::mobius(order : Poset) -> Kernel raise OrderError {
  Kernel::zeta(order).inverse()
}

///|
/// Solve a*x=b in the incidence algebra; errors retain integer-ring semantics.
pub fn Kernel::solve_right(
  self : Kernel,
  rhs : Kernel,
) -> Kernel raise OrderError {
  self.compatible(rhs)
  self.inverse().convolve(rhs)
}

///|
/// Solve x*a=b. This differs from solve_right for noncommuting kernels.
pub fn Kernel::solve_left(
  self : Kernel,
  rhs : Kernel,
) -> Kernel raise OrderError {
  self.compatible(rhs)
  rhs.convolve(self.inverse())
}
