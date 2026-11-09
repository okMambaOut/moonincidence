///|
const I64_MAX : Int64 = 9223372036854775807L

///|
const I64_MIN : Int64 = -9223372036854775808L

///|
fn checked_add(a : Int64, b : Int64) -> Int64 raise OrderError {
  if (b > 0L && a > I64_MAX - b) || (b < 0L && a < I64_MIN - b) {
    raise ArithmeticOverflow
  }
  a + b
}

///|
fn checked_sub(a : Int64, b : Int64) -> Int64 raise OrderError {
  if (b > 0L && a < I64_MIN + b) || (b < 0L && a > I64_MAX + b) {
    raise ArithmeticOverflow
  }
  a - b
}

///|
fn checked_mul(a : Int64, b : Int64) -> Int64 raise OrderError {
  if a == 0L || b == 0L {
    return 0L
  }
  let overflow = if a > 0L {
    if b > 0L {
      a > I64_MAX / b
    } else {
      b < I64_MIN / a
    }
  } else if b > 0L {
    a < I64_MIN / b
  } else {
    a < I64_MAX / b
  }
  if overflow {
    raise ArithmeticOverflow
  }
  a * b
}

///|
fn checked_neg(a : Int64) -> Int64 raise OrderError {
  checked_sub(0L, a)
}
