///|
test "convolution laws and noncommutativity" {
  let p = Poset::chain(3)
  let a = Kernel::from_entries(p, [(0, 1, 2L)])
  let b = Kernel::from_entries(p, [(1, 2, 3L)])
  let z = Kernel::zeta(p)
  let d = Kernel::delta(p)
  assert_eq(a.convolve(b).coefficient(0, 2), 6L)
  assert_eq(b.convolve(a), Kernel::zero(p))
  assert_eq(z.convolve(d), z)
  assert_eq(d.convolve(z), z)
  assert_eq(a.convolve(b).convolve(z), a.convolve(b.convolve(z)))
  assert_eq(a.convolve(b).dual(), b.dual().convolve(a.dual()))
}

///|
test "tensor and interval restriction respect indexing" {
  let p = Poset::chain(2)
  let z = Kernel::zeta(p)
  assert_eq(z.tensor(z), Kernel::zeta(p.product(p)))
  assert_eq(z.tensor(z).restrict([0, 3]), Kernel::zeta(Poset::chain(2)))
  assert_eq(
    Kernel::delta(Poset::chain(0))
    .convolve(Kernel::zeta(Poset::chain(0)))
    .matrix(),
    [],
  )
}
