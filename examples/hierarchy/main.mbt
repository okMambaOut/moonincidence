///|
fn main raise {
  // 0=source, 1=left, 2=right, 3=join, 4=side; overlapping paths count once.
  let p = @incidence.Poset::from_relations(5, [
    (0, 1),
    (0, 2),
    (1, 3),
    (2, 3),
    (0, 4),
  ])
  let raw = [3L, 7L, 11L, 13L, 5L]
  let aggregates = @incidence.Kernel::zeta(p).apply_lower(raw)
  let recovered = @incidence.Kernel::mobius(p).apply_lower(aggregates)
  assert_eq(aggregates, [3L, 10L, 14L, 34L, 8L])
  assert_eq(recovered, raw)
  println("hierarchy aggregates: \{@debug.to_string(aggregates)}")
  println("recovered local values: \{@debug.to_string(recovered)}")
}
