///|
test "canonical families have expected order invariants" {
  assert_eq(Poset::chain(5).height(), 5)
  assert_eq(Poset::antichain(5).height(), 1)
  let b = Poset::boolean_lattice(3)
  assert_eq(b.size(), 8)
  assert_eq(b.height(), 4)
  assert_eq(b.covers().length(), 12)
  assert_eq(Poset::divisibility([6, 1, 3, 2]).minimal(), [1])
  assert_eq(Poset::boolean_lattice(0).size(), 1)
  assert_eq(Poset::chain(0).height(), 0)
}

///|
test "families validate domains" {
  let zero = try {
    let _ = Poset::divisibility([1, 0])
    false
  } catch {
    InvalidSubset => true
    _ => false
  }
  assert_true(zero)
  let large = try {
    let _ = Poset::boolean_lattice(9)
    false
  } catch {
    InvalidSize(9) => true
    _ => false
  }
  assert_true(large)
}
