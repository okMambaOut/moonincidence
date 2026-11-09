///|
fn main raise {
  // Two optional capabilities share one prerequisite and unlock a final feature.
  let p = @incidence.Poset::from_relations(4, [(0, 1), (0, 2), (1, 3), (2, 3)])
  let left = @incidence.Ideal::generated(p, [1])
  let right = @incidence.Ideal::generated(p, [2])
  let merged = left.join(right)
  let shared = left.meet(right)
  let valid = p.enumerate_ideals(100, 100)
  let decomposition = p.chain_decomposition()
  assert_eq(merged.vertices(), [0, 1, 2])
  assert_eq(shared.vertices(), [0])
  assert_eq(merged.addable(), [3])
  assert_eq(merged.removable(), [1, 2])
  assert_eq(valid.length(), 6)
  assert_eq(decomposition.chains.length(), 2)
  println(
    "merged configuration: \{@debug.to_string(merged.vertices())}; shared: \{@debug.to_string(shared.vertices())}",
  )
  println(
    "addable: \{@debug.to_string(merged.addable())}; removable: \{@debug.to_string(merged.removable())}",
  )
  println(
    "closed configurations: \{valid.length()}; minimum chain count: \{p.width()}",
  )
}
