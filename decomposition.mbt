///|
/// A minimum chain partition and a maximum antichain, with equal cardinalities.
/// Output arrays are independent snapshots, not mutable state inside Poset.
pub(all) struct ChainDecomposition {
  chains : Array[Array[Int32]]
  antichain : Array[Int32]
} derive(Debug)

///|
pub extend ChainDecomposition with @debug.Debug::{to_repr}

///|
/// Dilworth decomposition through maximum matching in the strict-order graph.
pub fn Poset::chain_decomposition(self : Poset) -> ChainDecomposition {
  let n = self.count
  let matched_right = Array::make(n, -1)
  fn augment(x : Int32, seen : Array[Bool]) -> Bool {
    for y in 0..<n {
      if x != y && self.rel(x, y) && !seen[y] {
        seen[y] = true
        if matched_right[y] < 0 || augment(matched_right[y], seen) {
          matched_right[y] = x
          return true
        }
      }
    }
    false
  }
  for x in 0..<n {
    let _ = augment(x, Array::make(n, false))
  }
  let matched_left = Array::make(n, -1)
  for y in 0..<n {
    if matched_right[y] >= 0 {
      matched_left[matched_right[y]] = y
    }
  }
  let chains : Array[Array[Int32]] = []
  for start in 0..<n {
    if matched_right[start] < 0 {
      let chain : Array[Int32] = []
      let mut x = start
      while x >= 0 {
        chain.push(x)
        x = matched_left[x]
      }
      chains.push(chain)
    }
  }
  // Alternating reachability gives a minimum vertex cover in the bipartite graph.
  let left_reached = Array::make(n, false)
  let right_reached = Array::make(n, false)
  let queue : Array[Int32] = []
  for x in 0..<n {
    if matched_left[x] < 0 {
      left_reached[x] = true
      queue.push(x)
    }
  }
  let mut head = 0
  while head < queue.length() {
    let x = queue[head]
    head += 1
    for y in 0..<n {
      if x != y && self.rel(x, y) && matched_left[x] != y && !right_reached[y] {
        right_reached[y] = true
        let next = matched_right[y]
        if next >= 0 && !left_reached[next] {
          left_reached[next] = true
          queue.push(next)
        }
      }
    }
  }
  let antichain : Array[Int32] = []
  for x in 0..<n {
    if left_reached[x] && !right_reached[x] {
      antichain.push(x)
    }
  }
  { chains, antichain, }
}

///|
pub fn Poset::width(self : Poset) -> Int32 {
  self.chain_decomposition().chains.length()
}
