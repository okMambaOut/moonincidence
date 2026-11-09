///|
test "diamond intervals and covers" {
  let p = Poset::from_relations(4, [(3, 0), (3, 1), (0, 2), (1, 2)])
  assert_eq(p.minimal(), [3])
  assert_eq(p.maximal(), [2])
  assert_eq(p.height(), 3)
  assert_eq(p.interval(3, 2), [0, 1, 2, 3])
  assert_eq(p.interval(2, 3), [])
  assert_eq(p.covers(), [(0, 2), (1, 2), (3, 0), (3, 1)])
  assert_eq(p.predecessors(2), [0, 1, 3])
  assert_eq(p.successors(3), [0, 1, 2])
  assert_true(p.is_antichain([0, 1]))
  assert_false(p.is_chain([0, 1]))
  assert_true(p.is_chain([3, 1, 2]))
  assert_false(p.comparable(0, 1))
  assert_true(p.less(3, 2))
}

///|
test "empty order has zero height and no endpoints" {
  let p = Poset::from_relations(0, [])
  assert_eq(p.height(), 0)
  assert_eq(p.minimal(), [])
  assert_true(p.is_chain([]))
  assert_true(p.is_antichain([]))
}
