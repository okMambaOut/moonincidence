///|
test "sum and product comparison contracts" {
  let c = Poset::from_relations(2, [(1, 0)])
  let a = Poset::from_relations(2, [])
  assert_eq(c.disjoint_sum(a).minimal(), [1, 2, 3])
  assert_eq(c.ordinal_sum(a).minimal(), [1])
  assert_eq(c.ordinal_sum(a).maximal(), [2, 3])
  assert_eq(c.product(c).height(), 3)
  assert_eq(c.product(c).minimal(), [3])
  assert_eq(c.product(c).maximal(), [0])
  assert_eq(a.bounded().height(), 3)
  assert_eq(c.product(Poset::from_relations(0, [])).size(), 0)
}

///|
test "composition refuses excess storage before allocation" {
  let p = Poset::from_relations(17, [])
  let too_large = try {
    let _ = p.product(p)
    false
  } catch {
    InvalidSize(289) => true
    _ => false
  }
  assert_true(too_large)
}
