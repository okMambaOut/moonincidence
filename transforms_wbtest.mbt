///|
test "arbitrary hierarchy aggregation roundtrips in both directions" {
  let p = Poset::from_relations(5, [(3, 0), (0, 2), (1, 2), (3, 4)])
  let k = Kernel::zeta(p)
  let values = [7L, -2L, 10L, 3L, 9L]
  assert_eq(k.solve_lower(k.apply_lower(values)), values)
  assert_eq(k.solve_upper(k.apply_upper(values)), values)
  assert_eq(Kernel::mobius(p).apply_lower(k.apply_lower(values)), values)
  assert_eq(Kernel::mobius(p).apply_upper(k.apply_upper(values)), values)
  assert_eq(values, [7L, -2L, 10L, 3L, 9L])
}

///|
test "vector dimension unit diagonals and overflow are checked" {
  let k = Kernel::zeta(Poset::chain(2))
  let dimension = try {
    let _ = k.apply_lower([1L])
    false
  } catch {
    DimensionMismatch => true
    _ => false
  }
  assert_true(dimension)
  let overflow = try {
    let _ = k.apply_lower([I64_MAX, 1L])
    false
  } catch {
    ArithmeticOverflow => true
    _ => false
  }
  assert_true(overflow)
  let nonunit = try {
    let _ = k.with_coefficient(0, 0, 0L).solve_upper([0L, 0L])
    false
  } catch {
    NonUnitDiagonal(0) => true
    _ => false
  }
  assert_true(nonunit)
}
