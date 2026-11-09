///|
/// Number of order-preserving maps into a chain of `labels` labels.
/// strict=true requires x<y => f(x)<f(y); otherwise f(x)<=f(y).
/// Counts weak multichains of ideals; strict maps allow only antichain layers.
/// max_states charges ideal-search nodes, transition pairs and DP transitions.
pub fn Poset::order_polynomial(
  self : Poset,
  labels : Int32,
  strict : Bool,
  max_states : Int32,
  max_ideals : Int32,
) -> Int64 raise OrderError {
  if labels < 0 {
    raise InvalidSubset
  }
  let budget = WorkBudget::create(max_states)
  let ideals = self.ideals_with_budget(budget, max_ideals)
  let count = ideals.length()
  let predecessors : Array[Array[Int32]] = Array::makei(count, fn(_) { [] })
  let mut empty = -1
  let mut full = -1
  for i in 0..<count {
    if ideals[i].size() == 0 {
      empty = i
    }
    if ideals[i].size() == self.count {
      full = i
    }
    for j in 0..<count {
      budget.step()
      if ideals[j].is_subset_of(ideals[i]) {
        let mut allowed = true
        if strict {
          for x in 0..<self.count {
            if ideals[i].included[x] && !ideals[j].included[x] {
              for y in 0..<self.count {
                if y != x &&
                  ideals[i].included[y] &&
                  !ideals[j].included[y] &&
                  self.rel(x, y) {
                  allowed = false
                  break
                }
              }
            }
            if !allowed {
              break
            }
          }
        }
        if allowed {
          predecessors[i].push(j)
        }
      }
    }
  }
  let mut previous = Array::make(count, 0L)
  previous[empty] = 1L
  for _ in 0..<labels {
    let next = Array::make(count, 0L)
    for i in 0..<count {
      for j in predecessors[i] {
        budget.step()
        next[i] = checked_add(next[i], previous[j])
      }
    }
    previous = next
  }
  previous[full]
}
