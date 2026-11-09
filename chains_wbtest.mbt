///|
test "chain polynomials and Hall alternating formula" {
  let p = Poset::boolean_lattice(2)
  assert_eq(p.interval_chain_counts(0, 3), [0L, 1L, 2L, 0L])
  assert_eq(p.chain_counts(), [1L, 4L, 5L, 2L, 0L])
  assert_eq(p.reduced_interval_euler(0, 3), 1L)
  assert_eq(Poset::chain(0).chain_counts(), [1L])
  let strict = Kernel::zeta(p).subtract(Kernel::delta(p))
  assert_eq(strict.power(2).coefficient(0, 3), 2L)
  assert_eq(strict.power(4), Kernel::zero(p))
  assert_eq(strict.power(0), Kernel::delta(p))
}

///|
test "chain Mobius alternating formula holds for all intervals" {
  let p = Poset::divisibility([1, 2, 3, 4, 6, 12])
  let mu = Kernel::mobius(p)
  for x in 0..<p.size() {
    for y in 0..<p.size() {
      if p.less(x, y) {
        assert_eq(p.reduced_interval_euler(x, y), mu.coefficient(x, y))
      }
    }
  }
}
