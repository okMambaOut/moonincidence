///|
/// Incidence convolution, with x<=z<=y and checked intermediate arithmetic.
/// Multiplication is generally noncommutative.
pub fn Kernel::convolve(
  self : Kernel,
  other : Kernel,
) -> Kernel raise OrderError {
  self.compatible(other)
  let n = self.order.count
  let coefficients = Array::make(n * n, 0L)
  for x in 0..<n {
    for y in 0..<n {
      if self.order.rel(x, y) {
        let mut sum = 0L
        for z in 0..<n {
          if self.order.rel(x, z) && self.order.rel(z, y) {
            let term = checked_mul(
              self.coefficients[x * n + z],
              other.coefficients[z * n + y],
            )
            sum = checked_add(sum, term)
          }
        }
        coefficients[x * n + y] = sum
      }
    }
  }
  { order: self.order, coefficients, }
}

///|
/// Tensor product follows Poset::product's pair-index convention.
pub fn Kernel::tensor(self : Kernel, other : Kernel) -> Kernel raise OrderError {
  let order = self.order.product(other.order)
  let n = order.count
  let b = other.order.count
  let a = self.order.count
  let coefficients = Array::make(n * n, 0L)
  for x in 0..<n {
    for y in 0..<n {
      if order.rel(x, y) {
        coefficients[x * n + y] = checked_mul(
          self.coefficients[x / b * a + y / b],
          other.coefficients[x % b * b + y % b],
        )
      }
    }
  }
  { order, coefficients, }
}

///|
/// Reversing the order reverses the convolution factors: (ab)^op=b^op a^op.
pub fn Kernel::dual(self : Kernel) -> Kernel {
  let order = self.order.dual()
  let n = order.count
  let coefficients = Array::makei(n * n, fn(k) {
    self.coefficients[k % n * n + k / n]
  })
  { order, coefficients, }
}

///|
/// Restrict to an order-convex subset when preserving convolution is required.
/// Any subset is accepted here; the caller is responsible for that distinction.
pub fn Kernel::restrict(
  self : Kernel,
  vertices : Array[Int32],
) -> Kernel raise OrderError {
  let order = self.order.induced(vertices)
  let n = vertices.length()
  let coefficients = Array::makei(n * n, fn(k) {
    self.coefficients[vertices[k / n] * self.order.count + vertices[k % n]]
  })
  { order, coefficients, }
}
