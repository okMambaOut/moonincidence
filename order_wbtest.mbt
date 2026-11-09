///|
test "closure preserves input labels and defensive copies" {
  let edges = [(2, 0), (0, 1)]
  let p = Poset::from_relations(3, edges)
  edges.push((1, 2))
  assert_true(p.leq(2, 1))
  assert_false(p.leq(1, 2))
  let m = p.matrix()
  m[2][1] = false
  assert_true(p.leq(2, 1))
  assert_eq(Poset::from_matrix(p.matrix()), p)
}

///|
test "empty singleton and invalid order" {
  assert_eq(Poset::from_relations(0, []).size(), 0)
  assert_true(Poset::from_relations(1, []).leq(0, 0))
  let cycle = try {
    let _ = Poset::from_relations(2, [(0, 1), (1, 0)])
    false
  } catch {
    Cycle => true
    _ => false
  }
  assert_true(cycle)
  let bad = try {
    let _ = Poset::from_matrix([[true, true], [true, true]])
    false
  } catch {
    InvalidMatrix => true
    _ => false
  }
  assert_true(bad)
  let vertex = try {
    let _ = Poset::from_relations(2, [(0, 2)])
    false
  } catch {
    InvalidVertex(2) => true
    _ => false
  }
  assert_true(vertex)
}
