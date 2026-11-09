///|
test "kernel import and updates preserve interval support" {
  let p = Poset::chain(2)
  let k = Kernel::from_entries(p, [(0, 0, 2L), (0, 1, -3L)])
  assert_eq(k.coefficient(1, 0), 0L)
  assert_eq(k.with_coefficient(0, 1, 9L).coefficient(0, 1), 9L)
  assert_eq(k.coefficient(0, 1), -3L)
  let m = k.matrix()
  let q = Kernel::from_matrix(p, m)
  m[0][1] = 99L
  assert_eq(q, k)
  assert_eq(k.add(k).subtract(k), k)
  assert_eq(k.scale(-2L).coefficient(0, 1), 6L)
  assert_eq(k.poset(), p)
}

///|
test "kernels reject invalid coefficients and order mismatch" {
  let p = Poset::antichain(2)
  let wrong = try {
    let _ = Kernel::from_entries(p, [(0, 1, 0L)])
    false
  } catch {
    InvalidCoefficient(0, 1) => true
    _ => false
  }
  assert_true(wrong)
  let duplicate = try {
    let _ = Kernel::from_entries(p, [(0, 0, 0L), (0, 0, 1L)])
    false
  } catch {
    InvalidCoefficient(0, 0) => true
    _ => false
  }
  assert_true(duplicate)
  let incompatible = try {
    let _ = Kernel::zeta(p).add(Kernel::zeta(Poset::chain(2)))
    false
  } catch {
    IncompatibleOrders => true
    _ => false
  }
  assert_true(incompatible)
}
