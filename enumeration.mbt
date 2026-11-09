///|
priv struct WorkBudget {
  mut remaining : Int32
}

///|
fn WorkBudget::create(max_states : Int32) -> WorkBudget raise OrderError {
  if max_states <= 0 {
    raise InvalidBudget
  }
  { remaining: max_states, }
}

///|
fn WorkBudget::step(self : WorkBudget) -> Unit raise OrderError {
  if self.remaining == 0 {
    raise BudgetExceeded
  }
  self.remaining -= 1
}

///|
/// Complete ideal enumeration, excluding before including in internal linear order.
/// If either bound is insufficient, raises and returns no partial array.
pub fn Poset::enumerate_ideals(
  self : Poset,
  max_states : Int32,
  max_results : Int32,
) -> Array[Ideal] raise OrderError {
  self.ideals_with_budget(WorkBudget::create(max_states), max_results)
}

///|
fn Poset::ideals_with_budget(
  self : Poset,
  budget : WorkBudget,
  max_results : Int32,
) -> Array[Ideal] raise OrderError {
  if max_results <= 0 {
    raise InvalidBudget
  }
  let included = Array::make(self.count, false)
  let out : Array[Ideal] = []
  fn visit(depth : Int32) -> Unit raise OrderError {
    budget.step()
    if depth == self.count {
      if out.length() >= max_results {
        raise BudgetExceeded
      }
      out.push({ order: self, included: included.copy(), })
      return
    }
    let y = self.linear[depth]
    visit(depth + 1)
    let mut ready = true
    for x in 0..<self.count {
      if x != y && self.rel(x, y) && !included[x] {
        ready = false
        break
      }
    }
    if ready {
      included[y] = true
      visit(depth + 1)
      included[y] = false
    }
  }
  visit(0)
  out
}

///|
/// Rank generating coefficients of the ideal lattice, indexed by ideal size.
pub fn Poset::ideal_size_counts(
  self : Poset,
  max_states : Int32,
  max_results : Int32,
) -> Array[Int64] raise OrderError {
  let ideals = self.enumerate_ideals(max_states, max_results)
  let counts = Array::make(self.count + 1, 0L)
  for ideal in ideals {
    let k = ideal.size()
    counts[k] = checked_add(counts[k], 1L)
  }
  counts
}

///|
/// Complete lexicographic linear extensions; limit exhaustion is an error.
pub fn Poset::enumerate_extensions(
  self : Poset,
  max_states : Int32,
  max_results : Int32,
) -> Array[Array[Int32]] raise OrderError {
  let budget = WorkBudget::create(max_states)
  if max_results <= 0 {
    raise InvalidBudget
  }
  let out : Array[Array[Int32]] = []
  let path : Array[Int32] = []
  fn visit(ideal : Ideal) -> Unit raise OrderError {
    budget.step()
    if path.length() == self.count {
      if out.length() >= max_results {
        raise BudgetExceeded
      }
      out.push(path.copy())
      return
    }
    for x in ideal.addable() {
      path.push(x)
      visit(ideal.add(x))
      let _ = path.pop()
    }
  }
  visit(Ideal::empty(self))
  out
}
