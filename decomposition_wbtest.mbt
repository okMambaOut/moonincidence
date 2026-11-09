///|
test "Dilworth witnesses partition vertices and certify width" {
  for
    p in [
      Poset::boolean_lattice(3),
      Poset::chain(6),
      Poset::antichain(6),
      Poset::chain(0),
    ] {
    let d = p.chain_decomposition()
    assert_eq(d.chains.length(), d.antichain.length())
    assert_true(p.is_antichain(d.antichain))
    let seen = Array::make(p.size(), false)
    for c in d.chains {
      assert_true(p.is_chain(c))
      for x in c {
        assert_false(seen[x])
        seen[x] = true
      }
    }
    for included in seen {
      assert_true(included)
    }
  }
  assert_eq(Poset::boolean_lattice(3).width(), 3)
  assert_eq(Poset::antichain(6).width(), 6)
}
