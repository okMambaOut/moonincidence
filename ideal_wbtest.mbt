///|
test "ideal transitions preserve dependency closure" {
  let p = Poset::from_relations(4, [(2, 0), (2, 1), (0, 3), (1, 3)])
  let empty = Ideal::empty(p)
  assert_eq(empty.addable(), [2])
  let first = empty.add(2)
  assert_eq(first.addable(), [0, 1])
  assert_eq(first.add(0).removable(), [0])
  assert_eq(first.add(0).remove(0), first)
  assert_eq(Ideal::generated(p, [3]), Ideal::full(p))
  assert_eq(first.vertices(), [2])
  let bad = try {
    let _ = empty.add(0)
    false
  } catch {
    NotIdeal => true
    _ => false
  }
  assert_true(bad)
  let bad_remove = try {
    let _ = Ideal::full(p).remove(2)
    false
  } catch {
    NotIdeal => true
    _ => false
  }
  assert_true(bad_remove)
}

///|
test "ideal lattice join and meet obey absorption" {
  let p = Poset::antichain(3)
  let a = Ideal::from_vertices(p, [0, 2])
  let b = Ideal::from_vertices(p, [1, 2])
  assert_eq(a.join(b).vertices(), [0, 1, 2])
  assert_eq(a.meet(b).vertices(), [2])
  assert_eq(a.meet(a.join(b)), a)
  assert_true(a.meet(b).is_subset_of(a))
  assert_eq(a.size(), 2)
  assert_true(a.contains(0))
}
