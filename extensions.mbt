///|
struct ExtensionCounter {
  predecessors : Array[Int32]
  full : Int32
  memo : Map[Int32, Int64]
  budget : WorkBudget
}

///|
fn Poset::extension_counter(
  self : Poset,
  max_states : Int32,
) -> ExtensionCounter raise OrderError {
  let budget = WorkBudget::create(max_states)
  if self.count > 24 {
    raise TooManyVertices(self.count)
  }
  let predecessors = Array::make(self.count, 0)
  for y in 0..<self.count {
    for x in 0..<self.count {
      if x != y && self.rel(x, y) {
        predecessors[y] = predecessors[y] | (1 << x)
      }
    }
  }
  { predecessors, full: (1 << self.count) - 1, memo: Map::new(), budget, }
}

///|
fn ExtensionCounter::ready(
  self : ExtensionCounter,
  mask : Int32,
  x : Int32,
) -> Bool {
  (mask & (1 << x)) == 0 &&
  (mask & self.predecessors[x]) == self.predecessors[x]
}

///|
fn ExtensionCounter::count(
  self : ExtensionCounter,
  mask : Int32,
) -> Int64 raise OrderError {
  if self.memo.get(mask) is Some(value) {
    return value
  }
  self.budget.step()
  if mask == self.full {
    self.memo[mask] = 1L
    return 1L
  }
  let mut total = 0L
  for x in 0..<self.predecessors.length() {
    if self.ready(mask, x) {
      total = checked_add(total, self.count(mask | (1 << x)))
    }
  }
  self.memo[mask] = total
  total
}

///|
/// Exact number of linear extensions, using memoized ideal states (n<=24).
/// max_states counts distinct visited masks, including the terminal full mask.
pub fn Poset::count_extensions(
  self : Poset,
  max_states : Int32,
) -> Int64 raise OrderError {
  self.extension_counter(max_states).count(0)
}

///|
/// Validate a complete history rather than only testing adjacent comparisons.
pub fn Poset::is_extension(
  self : Poset,
  history : Array[Int32],
) -> Bool raise OrderError {
  let _ = self.subset_bits(history)
  if history.length() != self.count {
    return false
  }
  let positions = Array::make(self.count, 0)
  for i in 0..<history.length() {
    positions[history[i]] = i
  }
  for x in 0..<self.count {
    for y in 0..<self.count {
      if x != y && self.rel(x, y) && positions[x] >= positions[y] {
        return false
      }
    }
  }
  true
}
