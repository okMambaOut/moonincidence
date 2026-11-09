///|
/// Zero-based lexicographic rank, comparing the original integer vertex labels.
/// Requires representable total count as well as a valid complete extension.
pub fn Poset::rank_extension(
  self : Poset,
  history : Array[Int32],
  max_states : Int32,
) -> Int64 raise OrderError {
  if !self.is_extension(history) {
    raise NotExtension
  }
  let counter = self.extension_counter(max_states)
  let _ = counter.count(0)
  let mut mask = 0
  let mut rank = 0L
  for target in history {
    for x in 0..<target {
      if counter.ready(mask, x) {
        rank = checked_add(rank, counter.count(mask | (1 << x)))
      }
    }
    mask = mask | (1 << target)
  }
  rank
}

///|
/// Inverse of rank_extension; rank must satisfy 0 <= rank < total histories.
pub fn Poset::unrank_extension(
  self : Poset,
  rank : Int64,
  max_states : Int32,
) -> Array[Int32] raise OrderError {
  if rank < 0L {
    raise RankOutOfRange
  }
  let counter = self.extension_counter(max_states)
  let total = counter.count(0)
  if rank >= total {
    raise RankOutOfRange
  }
  let out : Array[Int32] = []
  let mut remaining = rank
  let mut mask = 0
  while mask != counter.full {
    let mut selected = -1
    for x in 0..<self.count {
      if counter.ready(mask, x) {
        let ways = counter.count(mask | (1 << x))
        if remaining < ways {
          selected = x
          break
        }
        remaining = checked_sub(remaining, ways)
      }
    }
    if selected < 0 {
      raise RankOutOfRange
    }
    out.push(selected)
    mask = mask | (1 << selected)
  }
  out
}
