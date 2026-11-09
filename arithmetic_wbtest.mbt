///|
test "checked arithmetic handles signed extrema" {
  assert_eq(checked_add(I64_MIN, I64_MAX), -1L)
  assert_eq(checked_sub(I64_MIN, I64_MIN), 0L)
  assert_eq(checked_mul(I64_MIN, 1L), I64_MIN)
  assert_eq(checked_mul(I64_MAX, -1L), -9223372036854775807L)
  assert_eq(checked_mul(-3037000499L, -3037000499L), 9223372030926249001L)
  assert_eq(checked_neg(0L), 0L)
}

///|
test "checked arithmetic rejects every sign of overflow" {
  for pair in [(I64_MAX, 1L), (I64_MIN, -1L)] {
    let overflow = try {
      let _ = checked_add(pair.0, pair.1)
      false
    } catch {
      ArithmeticOverflow => true
      _ => false
    }
    assert_true(overflow)
  }
  for
    pair in [
      (I64_MIN, -1L),
      (-1L, I64_MIN),
      (I64_MAX, 2L),
      (I64_MIN, 2L),
      (-3037000500L, -3037000500L),
    ] {
    let overflow = try {
      let _ = checked_mul(pair.0, pair.1)
      false
    } catch {
      ArithmeticOverflow => true
      _ => false
    }
    assert_true(overflow)
  }
  let overflow = try {
    let _ = checked_neg(I64_MIN)
    false
  } catch {
    ArithmeticOverflow => true
    _ => false
  }
  assert_true(overflow)
}
