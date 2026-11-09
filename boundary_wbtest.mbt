///|
test "full model boundary and bitmask counter boundary are distinct" {
  let p = Poset::chain(256)
  assert_eq(p.height(), 256)
  assert_true(p.leq(0, 255))
  let too_large = try {
    let _ = Poset::chain(257)
    false
  } catch {
    InvalidSize(257) => true
    _ => false
  }
  assert_true(too_large)
  let too_many = try {
    let _ = Poset::chain(25).count_extensions(100)
    false
  } catch {
    TooManyVertices(25) => true
    _ => false
  }
  assert_true(too_many)
  assert_eq(Poset::chain(24).count_extensions(25), 1L)
}

///|
test "empty order composition and tensor preserve empty semantics" {
  let p = Poset::chain(0)
  let q = Poset::chain(2)
  assert_eq(p.product(q), p)
  assert_eq(q.product(p), p)
  assert_eq(Kernel::zeta(q).tensor(Kernel::zeta(p)), Kernel::zero(p))
  assert_eq(Kernel::zeta(p).dual().restrict([]).inverse(), Kernel::zero(p))
  assert_eq(p.induced([]).dual().matrix(), [])
  assert_eq(p.count_extensions(1), 1L)
  assert_eq(p.order_polynomial(0, true, 2, 1), 1L)
}

///|
test "failed budget calls leave reusable immutable models unchanged" {
  let p = Poset::antichain(3)
  let failed = try {
    let _ = p.count_extensions(7)
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(failed)
  assert_eq(p.count_extensions(8), 6L)
  let bad = try {
    let _ = p.enumerate_extensions(100, 0)
    false
  } catch {
    InvalidBudget => true
    _ => false
  }
  assert_true(bad)
  let incomplete = try {
    let _ = p.order_polynomial(2, false, 1, 100)
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(incomplete)
  assert_eq(p.order_polynomial(2, false, 10000, 8), 8L)
  assert_eq(p.enumerate_extensions(100, 6).length(), 6)
}

///|
test "defensive ideal snapshots and failed transitions preserve prior values" {
  let p = Poset::chain(3)
  let vertices = [0, 1]
  let ideal = Ideal::from_vertices(p, vertices)
  vertices[0] = 2
  let snapshot = ideal.vertices()
  snapshot[0] = 2
  assert_eq(ideal.vertices(), [0, 1])
  let failed = try {
    let _ = ideal.remove(0)
    false
  } catch {
    NotIdeal => true
    _ => false
  }
  assert_true(failed)
  assert_eq(ideal.addable(), [2])
  assert_eq(ideal.add(2).vertices(), [0, 1, 2])
}

///|
test "intermediate overflow is rejected even when later terms could cancel" {
  let k = Kernel::zeta(Poset::chain(3))
  let failed = try {
    let _ = k.apply_lower([I64_MAX, 1L, -1L])
    false
  } catch {
    ArithmeticOverflow => true
    _ => false
  }
  assert_true(failed)
  assert_eq(k.apply_lower([I64_MAX, -1L, 1L]), [I64_MAX, I64_MAX - 1L, I64_MAX])
  let bad_inverse = try {
    let _ = Kernel::delta(Poset::chain(1)).with_coefficient(0, 0, 2L).inverse()
    false
  } catch {
    NonUnitDiagonal(0) => true
    _ => false
  }
  assert_true(bad_inverse)
}
