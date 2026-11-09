///|
/// Reverse every comparison while preserving vertex indices.
pub fn Poset::dual(self : Poset) -> Poset {
  let n = self.count
  let relation = Array::makei(n * n, fn(k) { self.rel(k % n, k / n) })
  order_from_closed(n, relation)
}

///|
/// Vertex i of the result represents vertices[i] of this order.
pub fn Poset::induced(
  self : Poset,
  vertices : Array[Int32],
) -> Poset raise OrderError {
  let _ = self.subset_bits(vertices)
  let n = vertices.length()
  let relation = Array::makei(n * n, fn(k) {
    self.rel(vertices[k / n], vertices[k % n])
  })
  order_from_closed(n, relation)
}

///|
/// Reindex using a complete permutation: new i denotes old permutation[i].
pub fn Poset::relabel(
  self : Poset,
  permutation : Array[Int32],
) -> Poset raise OrderError {
  if permutation.length() != self.count {
    raise DimensionMismatch
  }
  self.induced(permutation)
}

///|
pub fn Poset::lower_closure(
  self : Poset,
  vertices : Array[Int32],
) -> Array[Int32] raise OrderError {
  let _ = self.subset_bits(vertices)
  let out : Array[Int32] = []
  for x in 0..<self.count {
    for y in vertices {
      if self.rel(x, y) {
        out.push(x)
        break
      }
    }
  }
  out
}

///|
pub fn Poset::upper_closure(
  self : Poset,
  vertices : Array[Int32],
) -> Array[Int32] raise OrderError {
  let _ = self.subset_bits(vertices)
  let out : Array[Int32] = []
  for x in 0..<self.count {
    for y in vertices {
      if self.rel(y, x) {
        out.push(x)
        break
      }
    }
  }
  out
}

///|
/// Return minimal generators of an upper set (not a closure operation).
pub fn Poset::minimal_in(
  self : Poset,
  vertices : Array[Int32],
) -> Array[Int32] raise OrderError {
  let bits = self.subset_bits(vertices)
  let out : Array[Int32] = []
  for x in 0..<self.count {
    if bits[x] {
      let mut minimal = true
      for y in 0..<self.count {
        if y != x && bits[y] && self.rel(y, x) {
          minimal = false
          break
        }
      }
      if minimal {
        out.push(x)
      }
    }
  }
  out
}

///|
pub fn Poset::maximal_in(
  self : Poset,
  vertices : Array[Int32],
) -> Array[Int32] raise OrderError {
  self.dual().minimal_in(vertices)
}
