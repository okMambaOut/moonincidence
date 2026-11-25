///|
/// An immutable downward-closed subset of an indexed order.
#derive(Debug, Eq)
pub struct Ideal {
  priv order : Poset
  priv included : Array[Bool]
}

///|
pub extend Ideal with Eq::{equal, not_equal}

///|
pub extend Ideal with @debug.Debug::{to_repr}

///|
pub fn Ideal::empty(order : Poset) -> Ideal {
  { order, included: Array::make(order.count, false), }
}

///|
pub fn Ideal::full(order : Poset) -> Ideal {
  { order, included: Array::make(order.count, true), }
}

///|
/// Validate the supplied set without completing its missing dependencies.
pub fn Ideal::from_vertices(
  order : Poset,
  vertices : Array[Int32],
) -> Ideal raise OrderError {
  let included = order.subset_bits(vertices)
  for y in 0..<order.count {
    if included[y] {
      for x in 0..<order.count {
        if order.rel(x, y) && !included[x] {
          raise NotIdeal
        }
      }
    }
  }
  { order, included, }
}

///|
/// Generate the smallest ideal containing every supplied vertex.
pub fn Ideal::generated(
  order : Poset,
  vertices : Array[Int32],
) -> Ideal raise OrderError {
  Ideal::from_vertices(order, order.lower_closure(vertices))
}

///|
pub fn Ideal::vertices(self : Ideal) -> Array[Int32] {
  let out : Array[Int32] = []
  for x in 0..<self.order.count {
    if self.included[x] {
      out.push(x)
    }
  }
  out
}

///|
pub fn Ideal::size(self : Ideal) -> Int32 {
  let mut result = 0
  for present in self.included {
    if present {
      result += 1
    }
  }
  result
}

///|
pub fn Ideal::contains(self : Ideal, vertex : Int32) -> Bool raise OrderError {
  self.order.vertex(vertex)
  self.included[vertex]
}

///|
/// Minimal elements of the complement: precisely the legal one-element adds.
pub fn Ideal::addable(self : Ideal) -> Array[Int32] {
  let out : Array[Int32] = []
  for y in 0..<self.order.count {
    if !self.included[y] {
      let mut ready = true
      for x in 0..<self.order.count {
        if x != y && self.order.rel(x, y) && !self.included[x] {
          ready = false
          break
        }
      }
      if ready {
        out.push(y)
      }
    }
  }
  out
}

///|
pub fn Ideal::removable(self : Ideal) -> Array[Int32] {
  let out : Array[Int32] = []
  for x in 0..<self.order.count {
    if self.included[x] {
      let mut ready = true
      for y in 0..<self.order.count {
        if x != y && self.order.rel(x, y) && self.included[y] {
          ready = false
          break
        }
      }
      if ready {
        out.push(x)
      }
    }
  }
  out
}

///|
/// Idempotent for an included vertex; otherwise all predecessors must be present.
pub fn Ideal::add(self : Ideal, vertex : Int32) -> Ideal raise OrderError {
  self.order.vertex(vertex)
  if !self.included[vertex] && !self.addable().contains(vertex) {
    raise NotIdeal
  }
  let included = self.included.copy()
  included[vertex] = true
  { order: self.order, included, }
}

///|
pub fn Ideal::remove(self : Ideal, vertex : Int32) -> Ideal raise OrderError {
  self.order.vertex(vertex)
  if self.included[vertex] && !self.removable().contains(vertex) {
    raise NotIdeal
  }
  let included = self.included.copy()
  included[vertex] = false
  { order: self.order, included, }
}

///|
fn Ideal::compatible(self : Ideal, other : Ideal) -> Unit raise OrderError {
  if self.order != other.order {
    raise IncompatibleOrders
  }
}

///|
pub fn Ideal::join(self : Ideal, other : Ideal) -> Ideal raise OrderError {
  self.compatible(other)
  {
    order: self.order,
    included: Array::makei(self.order.count, fn(i) {
      self.included[i] || other.included[i]
    }),
  }
}

///|
pub fn Ideal::meet(self : Ideal, other : Ideal) -> Ideal raise OrderError {
  self.compatible(other)
  {
    order: self.order,
    included: Array::makei(self.order.count, fn(i) {
      self.included[i] && other.included[i]
    }),
  }
}

///|
pub fn Ideal::is_subset_of(
  self : Ideal,
  other : Ideal,
) -> Bool raise OrderError {
  self.compatible(other)
  for i in 0..<self.order.count {
    if self.included[i] && !other.included[i] {
      return false
    }
  }
  true
}
