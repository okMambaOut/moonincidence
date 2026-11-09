///|
test "duality closure and induced label mapping" {
  let p = Poset::from_relations(4, [(2, 0), (0, 1)])
  assert_eq(p.dual().dual(), p)
  assert_eq(p.lower_closure([1]), [0, 1, 2])
  assert_eq(p.upper_closure([2]), [0, 1, 2])
  assert_eq(p.minimal_in([0, 1, 3]), [0, 3])
  assert_eq(p.maximal_in([0, 1, 3]), [1, 3])
  let q = p.induced([1, 2, 3])
  assert_true(q.less(1, 0))
  assert_false(q.comparable(0, 2))
  assert_eq(p.relabel([3, 2, 1, 0]).relabel([3, 2, 1, 0]), p)
}

///|
test "induced orders reject duplicate and invalid labels" {
  let p = Poset::from_relations(2, [])
  let duplicate = try {
    let _ = p.induced([0, 0])
    false
  } catch {
    DuplicateVertex(0) => true
    _ => false
  }
  assert_true(duplicate)
  assert_eq(p.induced([]).size(), 0)
}
