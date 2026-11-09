///|
test "rank unrank agrees with independent enumeration order" {
  let p = Poset::from_relations(5, [(3, 1), (3, 0), (1, 4), (0, 2)])
  let histories = p.enumerate_extensions(1000, 1000)
  assert_eq(p.count_extensions(1000), histories.length().to_int64())
  for i in 0..<histories.length() {
    assert_eq(p.rank_extension(histories[i], 1000), i.to_int64())
    assert_eq(p.unrank_extension(i.to_int64(), 1000), histories[i])
  }
  assert_eq(Poset::chain(0).unrank_extension(0L, 1), [])
}

///|
test "history rank rejects invalid histories and bounds" {
  let p = Poset::chain(2)
  let invalid = try {
    let _ = p.rank_extension([1, 0], 3)
    false
  } catch {
    NotExtension => true
    _ => false
  }
  assert_true(invalid)
  for rank in [-1L, 1L] {
    let invalid_rank = try {
      let _ = p.unrank_extension(rank, 3)
      false
    } catch {
      RankOutOfRange => true
      _ => false
    }
    assert_true(invalid_rank)
  }
}
