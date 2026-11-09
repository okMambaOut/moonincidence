///|
test "general unit kernel has a two sided integer inverse" {
  let p = Poset::from_relations(3, [(2, 0), (0, 1)])
  let k = Kernel::from_entries(p, [
    (0, 0, -1L),
    (1, 1, 1L),
    (2, 2, -1L),
    (2, 0, 2L),
    (0, 1, 3L),
    (2, 1, 5L),
  ])
  let inv = k.inverse()
  assert_eq(k.convolve(inv), Kernel::delta(p))
  assert_eq(inv.convolve(k), Kernel::delta(p))
  assert_eq(k.solve_right(Kernel::delta(p)), inv)
  assert_eq(k.solve_left(Kernel::delta(p)), inv)
  assert_eq(inv.inverse(), k)
}

///|
test "Mobius values for diamond and chain and nonunits" {
  let b = Poset::boolean_lattice(2)
  assert_eq(Kernel::mobius(b).coefficient(0, 3), 1L)
  assert_eq(Kernel::mobius(Poset::chain(3)).coefficient(0, 2), 0L)
  let nonunit = try {
    let _ = Kernel::zeta(b).with_coefficient(0, 0, 2L).inverse()
    false
  } catch {
    NonUnitDiagonal(0) => true
    _ => false
  }
  assert_true(nonunit)
}
