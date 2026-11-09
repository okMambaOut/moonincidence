// Self-authored brute-force oracles, deliberately independent of ideal DP/matching.

///|
fn oracle_orders() -> Array[Poset] raise OrderError {
  let out : Array[Poset] = []
  for n in 0..<5 {
    let edges : Array[(Int32, Int32)] = []
    for x in 0..<n {
      for y in (x + 1)..<n {
        edges.push((x, y))
      }
    }
    for mask in 0..<(1 << edges.length()) {
      let chosen : Array[(Int32, Int32)] = []
      for k in 0..<edges.length() {
        if (mask & (1 << k)) != 0 {
          chosen.push(edges[k])
        }
      }
      let p = Poset::from_relations(n, chosen)
      out.push(p)
      // Reverse labels prevents numerical-index order from being an oracle.
      out.push(p.relabel(Array::makei(n, fn(i) { n - 1 - i })))
    }
  }
  out
}

///|
fn oracle_histories(p : Poset) -> Array[Array[Int32]] raise OrderError {
  let n = p.size()
  let out : Array[Array[Int32]] = []
  let path : Array[Int32] = []
  let used = Array::make(n, false)
  fn permute() -> Unit raise OrderError {
    if path.length() == n {
      let positions = Array::make(n, 0)
      for i in 0..<n {
        positions[path[i]] = i
      }
      for x in 0..<n {
        for y in 0..<n {
          if x != y && p.leq(x, y) && positions[x] >= positions[y] {
            return
          }
        }
      }
      out.push(path.copy())
      return
    }
    for v in 0..<n {
      if !used[v] {
        used[v] = true
        path.push(v)
        permute()
        let _ = path.pop()
        used[v] = false
      }
    }
  }
  permute()
  out
}

///|
test "exhaustive small DAGs: permutations versus enumeration count rank unrank" {
  let orders = oracle_orders()
  assert_eq(orders.length(), 152)
  for p in orders {
    let expected = oracle_histories(p)
    assert_eq(p.enumerate_extensions(1000, 1000), expected)
    assert_eq(p.count_extensions(1000), expected.length().to_int64())
    for i in 0..<expected.length() {
      assert_eq(p.rank_extension(expected[i], 1000), i.to_int64())
      assert_eq(p.unrank_extension(i.to_int64(), 1000), expected[i])
    }
  }
}

///|
test "exhaustive small DAGs: bit subsets versus ideals and Dilworth certificates" {
  for p in oracle_orders() {
    let n = p.size()
    let ideals = p.enumerate_ideals(1000, 1000)
    let mut ideal_count = 0
    let mut width = 0
    for mask in 0..<(1 << n) {
      let vertices : Array[Int32] = []
      for x in 0..<n {
        if (mask & (1 << x)) != 0 {
          vertices.push(x)
        }
      }
      let mut closed = true
      let mut antichain = true
      for y in vertices {
        for x in 0..<n {
          if p.leq(x, y) && (mask & (1 << x)) == 0 {
            closed = false
          }
        }
        for x in vertices {
          if x != y && p.leq(x, y) {
            antichain = false
          }
        }
      }
      if closed {
        ideal_count += 1
        assert_true(ideals.any(fn(ideal) { ideal.vertices() == vertices }))
      }
      if antichain && vertices.length() > width {
        width = vertices.length()
      }
    }
    assert_eq(ideals.length(), ideal_count)
    let d = p.chain_decomposition()
    assert_eq(d.chains.length(), width)
    assert_eq(d.antichain.length(), width)
    assert_true(p.is_antichain(d.antichain))
    let visits = Array::make(n, 0)
    for chain in d.chains {
      assert_true(p.is_chain(chain))
      for x in chain {
        visits[x] += 1
      }
    }
    assert_eq(visits, Array::make(n, 1))
  }
}

///|
fn oracle_labels(
  p : Poset,
  labels : Int32,
  strict : Bool,
) -> Int64 raise OrderError {
  let values = Array::make(p.size(), 0)
  let mut total = 0L
  fn assign(i : Int32) -> Unit raise OrderError {
    if i == values.length() {
      for x in 0..<p.size() {
        for y in 0..<p.size() {
          if x != y &&
            p.leq(x, y) &&
            (if strict {
              values[x] >= values[y]
            } else {
              values[x] > values[y]
            }) {
            return
          }
        }
      }
      total += 1L
      return
    }
    for value in 0..<labels {
      values[i] = value
      assign(i + 1)
    }
  }
  assign(0)
  total
}

///|
test "exhaustive small DAGs: direct label assignments versus order polynomials" {
  for p in oracle_orders() {
    for labels in 0..<4 {
      for strict in [false, true] {
        assert_eq(
          p.order_polynomial(labels, strict, 100000, 100),
          oracle_labels(p, labels, strict),
        )
      }
    }
  }
}

///|
test "exhaustive small DAGs: Mobius cancellation and arbitrary unit inverses" {
  for p in oracle_orders() {
    let z = Kernel::zeta(p)
    let mu = Kernel::mobius(p)
    assert_eq(z.convolve(mu), Kernel::delta(p))
    assert_eq(mu.convolve(z), Kernel::delta(p))
    let entries : Array[(Int32, Int32, Int64)] = []
    for x in 0..<p.size() {
      for y in 0..<p.size() {
        if p.leq(x, y) {
          entries.push(
            (x, y, if x == y { -1L } else { (x + y + 1).to_int64() }),
          )
        }
      }
    }
    let k = Kernel::from_entries(p, entries)
    assert_eq(k.convolve(k.inverse()), Kernel::delta(p))
    assert_eq(k.inverse().convolve(k), Kernel::delta(p))
  }
}
