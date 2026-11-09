///|
test "exact extension counts match independent known families" {
  assert_eq(Poset::antichain(6).count_extensions(64), 720L)
  assert_eq(Poset::chain(20).count_extensions(21), 1L)
  assert_eq(Poset::chain(0).count_extensions(1), 1L)
  let p = Poset::chain(3).disjoint_sum(Poset::chain(3))
  assert_eq(p.count_extensions(100), 20L)
  assert_true(p.is_extension([0, 3, 1, 4, 2, 5]))
  assert_false(p.is_extension([0, 2, 1, 3, 4, 5]))
  assert_false(p.is_extension([0, 1]))
}

///|
test "memoized counting enforces budgets and bitset boundary" {
  let exhausted = try {
    let _ = Poset::antichain(4).count_extensions(15)
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(exhausted)
  let too_large = try {
    let _ = Poset::chain(25).count_extensions(100)
    false
  } catch {
    TooManyVertices(25) => true
    _ => false
  }
  assert_true(too_large)
  assert_eq(Poset::chain(24).count_extensions(25), 1L)
}
