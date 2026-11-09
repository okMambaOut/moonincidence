///|
fn main raise {
  // schema precedes import and index; both precede verification.
  let p = @incidence.Poset::from_relations(4, [(0, 1), (0, 2), (1, 3), (2, 3)])
  let total = p.count_extensions(100)
  let selected = p.unrank_extension(1L, 100)
  let rank = p.rank_extension(selected, 100)
  assert_eq(total, 2L)
  assert_eq(selected, [0, 2, 1, 3])
  assert_eq(rank, 1L)
  println("legal histories: \{total}")
  println(
    "history at rank 1: \{@debug.to_string(selected)}; recovered rank: \{rank}",
  )
}
