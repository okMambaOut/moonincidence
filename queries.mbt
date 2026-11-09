///|
/// Strict comparability; vertices are checked even for equal arguments.
pub fn Poset::less(self : Poset, a : Int32, b : Int32) -> Bool raise OrderError {
  self.vertex(a)
  self.vertex(b)
  a != b && self.rel(a, b)
}

///|
pub fn Poset::comparable(
  self : Poset,
  a : Int32,
  b : Int32,
) -> Bool raise OrderError {
  self.vertex(a)
  self.vertex(b)
  self.rel(a, b) || self.rel(b, a)
}

///|
/// Strict predecessors, in ascending vertex-index order.
pub fn Poset::predecessors(
  self : Poset,
  v : Int32,
) -> Array[Int32] raise OrderError {
  self.vertex(v)
  let out : Array[Int32] = []
  for x in 0..<self.count {
    if x != v && self.rel(x, v) {
      out.push(x)
    }
  }
  out
}

///|
pub fn Poset::successors(
  self : Poset,
  v : Int32,
) -> Array[Int32] raise OrderError {
  self.vertex(v)
  let out : Array[Int32] = []
  for x in 0..<self.count {
    if x != v && self.rel(v, x) {
      out.push(x)
    }
  }
  out
}

///|
/// The closed interval [a,b], empty for incomparable or reversed endpoints.
pub fn Poset::interval(
  self : Poset,
  a : Int32,
  b : Int32,
) -> Array[Int32] raise OrderError {
  self.vertex(a)
  self.vertex(b)
  let out : Array[Int32] = []
  if self.rel(a, b) {
    for x in 0..<self.count {
      if self.rel(a, x) && self.rel(x, b) {
        out.push(x)
      }
    }
  }
  out
}

///|
pub fn Poset::minimal(self : Poset) -> Array[Int32] {
  let out : Array[Int32] = []
  for x in 0..<self.count {
    let mut found = false
    for y in 0..<self.count {
      if y != x && self.rel(y, x) {
        found = true
        break
      }
    }
    if !found {
      out.push(x)
    }
  }
  out
}

///|
pub fn Poset::maximal(self : Poset) -> Array[Int32] {
  let out : Array[Int32] = []
  for x in 0..<self.count {
    let mut found = false
    for y in 0..<self.count {
      if y != x && self.rel(x, y) {
        found = true
        break
      }
    }
    if !found {
      out.push(x)
    }
  }
  out
}

///|
/// Cover pairs x<y for which there is no intermediate vertex.
pub fn Poset::covers(self : Poset) -> Array[(Int32, Int32)] {
  let out : Array[(Int32, Int32)] = []
  for x in 0..<self.count {
    for y in 0..<self.count {
      if x != y && self.rel(x, y) {
        let mut covered = true
        for z in 0..<self.count {
          if z != x && z != y && self.rel(x, z) && self.rel(z, y) {
            covered = false
            break
          }
        }
        if covered {
          out.push((x, y))
        }
      }
    }
  }
  out
}

///|
/// Number of vertices in a longest chain, including both endpoints.
pub fn Poset::height(self : Poset) -> Int32 {
  let heights = Array::make(self.count, 1)
  let mut longest = 0
  for y in self.linear {
    for x in 0..<self.count {
      if x != y && self.rel(x, y) && heights[x] + 1 > heights[y] {
        heights[y] = heights[x] + 1
      }
    }
    if heights[y] > longest {
      longest = heights[y]
    }
  }
  longest
}

///|
/// Validate a subset once; duplicates are errors rather than silently collapsed.
fn Poset::subset_bits(
  self : Poset,
  vertices : Array[Int32],
) -> Array[Bool] raise OrderError {
  let bits = Array::make(self.count, false)
  for v in vertices {
    self.vertex(v)
    if bits[v] {
      raise DuplicateVertex(v)
    }
    bits[v] = true
  }
  bits
}

///|
pub fn Poset::is_chain(
  self : Poset,
  vertices : Array[Int32],
) -> Bool raise OrderError {
  let _ = self.subset_bits(vertices)
  for i in 0..<vertices.length() {
    for j in 0..<i {
      if !self.rel(vertices[i], vertices[j]) &&
        !self.rel(vertices[j], vertices[i]) {
        return false
      }
    }
  }
  true
}

///|
pub fn Poset::is_antichain(
  self : Poset,
  vertices : Array[Int32],
) -> Bool raise OrderError {
  let _ = self.subset_bits(vertices)
  for i in 0..<vertices.length() {
    for j in 0..<i {
      if self.rel(vertices[i], vertices[j]) ||
        self.rel(vertices[j], vertices[i]) {
        return false
      }
    }
  }
  true
}
