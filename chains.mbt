///|
/// Nonnegative convolution power, using repeated squaring. a^0 is delta.
pub fn Kernel::power(
  self : Kernel,
  exponent : Int32,
) -> Kernel raise OrderError {
  if exponent < 0 {
    raise InvalidSubset
  }
  let mut remaining = exponent
  let mut base = self
  let mut out = Kernel::delta(self.order)
  while remaining > 0 {
    if (remaining & 1) == 1 {
      out = out.convolve(base)
    }
    remaining = remaining >> 1
    if remaining > 0 {
      base = base.convolve(base)
    }
  }
  out
}

///|
/// Entry k counts strict chains from a to b with exactly k strict steps.
/// Length is size(), except the empty order has no valid endpoint.
pub fn Poset::interval_chain_counts(
  self : Poset,
  a : Int32,
  b : Int32,
) -> Array[Int64] raise OrderError {
  self.vertex(a)
  self.vertex(b)
  let n = self.count
  let result = Array::make(n, 0L)
  if !self.rel(a, b) {
    return result
  }
  let mut previous = Array::make(n, 0L)
  previous[a] = 1L
  result[0] = if a == b { 1L } else { 0L }
  for length in 1..<n {
    let next = Array::make(n, 0L)
    for y in self.linear {
      if self.rel(a, y) && self.rel(y, b) {
        for x in 0..<n {
          if x != y && self.rel(x, y) {
            next[y] = checked_add(next[y], previous[x])
          }
        }
      }
    }
    result[length] = next[b]
    previous = next
  }
  result
}

///|
/// Entry k counts k-vertex chains anywhere in the order; entry 0 is one.
pub fn Poset::chain_counts(self : Poset) -> Array[Int64] raise OrderError {
  let n = self.count
  let result = Array::make(n + 1, 0L)
  result[0] = 1L
  let mut previous = Array::make(n, 1L)
  for length in 1..<=n {
    let mut total = 0L
    for x in 0..<n {
      total = checked_add(total, previous[x])
    }
    result[length] = total
    if length < n {
      let next = Array::make(n, 0L)
      for y in 0..<n {
        for x in 0..<n {
          if x != y && self.rel(x, y) {
            next[y] = checked_add(next[y], previous[x])
          }
        }
      }
      previous = next
    }
  }
  result
}

///|
/// Euler characteristic of the open interval's order complex, reduced by one.
/// For a<b this equals the Mobius coefficient mu(a,b).
pub fn Poset::reduced_interval_euler(
  self : Poset,
  a : Int32,
  b : Int32,
) -> Int64 raise OrderError {
  self.vertex(a)
  self.vertex(b)
  if a == b || !self.rel(a, b) {
    raise InvalidSubset
  }
  let counts = self.interval_chain_counts(a, b)
  let mut result = 0L
  for k in 1..<counts.length() {
    result = if (k & 1) == 1 {
      checked_sub(result, counts[k])
    } else {
      checked_add(result, counts[k])
    }
  }
  result
}
