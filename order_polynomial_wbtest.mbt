///|
test "order polynomial evaluations agree with elementary formulas" {
  let c = Poset::chain(3)
  assert_eq(c.order_polynomial(3, false, 1000, 4), 10L)
  assert_eq(c.order_polynomial(3, true, 1000, 4), 1L)
  assert_eq(c.order_polynomial(2, true, 1000, 4), 0L)
  assert_eq(Poset::antichain(3).order_polynomial(3, true, 2000, 8), 27L)
  assert_eq(Poset::chain(0).order_polynomial(0, false, 10, 1), 1L)
  assert_eq(c.order_polynomial(0, false, 1000, 4), 0L)
}

///|
test "order polynomial charges work after enumeration" {
  let exhausted = try {
    let _ = Poset::antichain(3).order_polynomial(100000, false, 100, 8)
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(exhausted)
}
