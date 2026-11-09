///|
test "complete ideal enumeration and rank generating counts" {
  let p = Poset::boolean_lattice(2)
  assert_eq(p.enumerate_ideals(100, 10).length(), 6)
  assert_eq(p.ideal_size_counts(100, 10), [1L, 1L, 2L, 1L, 1L])
  assert_eq(Poset::antichain(3).enumerate_ideals(15, 8).length(), 8)
  assert_eq(Poset::chain(0).enumerate_extensions(1, 1), [[]])
}

///|
test "enumeration never labels truncation complete" {
  let p = Poset::antichain(3)
  let states = try {
    let _ = p.enumerate_ideals(14, 8)
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(states)
  let results = try {
    let _ = p.enumerate_ideals(100, 7)
    false
  } catch {
    BudgetExceeded => true
    _ => false
  }
  assert_true(results)
  let extensions = p.enumerate_extensions(100, 6)
  assert_eq(extensions.length(), 6)
  assert_eq(extensions[0], [0, 1, 2])
  assert_eq(extensions[5], [2, 1, 0])
}
