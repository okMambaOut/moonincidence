# MoonIncidence

任意有限偏序上的整数关联代数、Möbius 反演和有预算的精确组合计算。模块为 `okMambaOut/moonincidence@0.1.0`，采用 MIT 许可证。

当层级存在共享祖先时，按树递归相加容易重复计数；当依赖关系只有部分先后约束时，单个拓扑序也不能回答“有多少合法历史”“第 k 个历史是什么”。本库把这些问题表示为明确的偏序、区间系数和下闭集，提供可组合的公共 API。

## 使用者与完整流程

- 数据分析系统：输入带共享祖先的层级与局部数值，通过 ζ 聚合得到各节点累计值，再用 Möbius 反演恢复局部贡献。示例校验了菱形关系中的共享祖先只计一次。
- 依赖审计和模型探索工具：输入事件的先后约束，精确计数所有合法历史，通过零起点排名选择、保存和恢复指定历史。结果是完整排列，拒绝重复或违反依赖的历史。
- 配置及特性组合工具：输入功能依赖和期望功能，求闭包生成合法配置，合并或求交两个配置，并给出可添加／可删除的边界。枚举接口返回所有闭合配置，超出预算则报错。

## 安装与环境

使用 MoonBit 官方工具链，`moonc` 不低于 **0.10.16**。本版本固定验证于 `moon 0.1.20261016` / `moonc v0.10.16+b1a0e846e`。支持 wasm-gc、wasm、js、native；JS 需要 Node.js，native 还需要平台 C 工具链。

在已有 MoonBit 模块中执行：

```sh
moon add okMambaOut/moonincidence@0.1.0
```

在消费包的 `moon.pkg` 中声明：

```moonbit
import {
  "okMambaOut/moonincidence" @incidence,
}
pkgtype(kind: "executable")
```

保存以下内容为该包的 `main.mbt`，执行 `moon run .`（如果包位于子目录，则用对应目录）：

```moonbit
fn main raise {
  let p = @incidence.Poset::from_relations(4, [
    (0, 1), (0, 2), (1, 3), (2, 3),
  ])
  let raw = [3L, 7L, 11L, 13L]
  let totals = @incidence.Kernel::zeta(p).apply_lower(raw)
  assert_eq(totals, [3L, 10L, 14L, 34L])
  let recovered = @incidence.Kernel::mobius(p).apply_lower(totals)
  assert_eq(recovered, raw)
  assert_eq(p.count_extensions(100), 2L)
  assert_eq(p.unrank_extension(1L, 100), [0, 2, 1, 3])
  println("aggregation and history checks passed")
}
```

## 数据模型与 API

完整接口见 [pkg.generated.mbti](pkg.generated.mbti)。`Poset`、`Kernel`、`Ideal` 的字段私有，导入数组会复制，导出的矩阵和顶点数组也不会暴露内部可变状态。

| 类型 | 主要能力 |
| --- | --- |
| `Poset` | 关系闭包、严格矩阵导入、区间、覆盖关系、对偶、诱导子序、重编号、和／积、链／布尔格／整除序 |
| `Kernel` | δ、ζ、Möbius、区间系数导入、加减缩放、非交换卷积、整数单位求逆、左右方程、向量变换、张量积 |
| `Ideal` | 下闭集校验、生成闭包、交并、包含、单步增删、可添加／删除的边界 |
| 精确组合 | 下闭集与历史完整枚举、历史计数／排名／反排名、链计数、最小链分解及最大反链、严格／弱序多项式求值 |

约定 `x <= y` 表示 x 是 y 的前置元素。`from_relations(n, edges)` 输入严格约束 `(x,y)`，计算自反传递闭包；冗余边允许，环及自环拒绝。编号始终为 `0..n-1`，不要求数字顺序符合拓扑顺序。`from_matrix` 输入已经闭合的完整关系矩阵，不自动修复非法矩阵。`induced(vertices)` 的新编号 i 表示原来的 `vertices[i]`；`relabel` 需要完整排列。

卷积定义为 `(f*g)(x,z) = sum_{x<=y<=z} f(x,y)*g(y,z)`，通常不交换。`apply_lower(v)[y] = sum_{x<=y} f(x,y)*v[x]`，`apply_upper(v)[x] = sum_{x<=y} f(x,y)*v[y]`。`solve_lower/upper` 直接三角求解；`solve_right(b)` 求 `self*x=b`，`solve_left(b)` 求 `x*self=b`。单位对角元必须为 `+1` 或 `-1`；不提供有理数求逆。

`Kernel::from_entries` 拒绝重复或不可比的系数项；`coefficient` 对合法但不可比的顶点对返回零。`restrict` 可接受任意子集，但只有序凸子集能保证限制保持卷积。`dual` 会反转卷积因子的顺序。

`chain_counts()[k]` 为包含 k 个顶点的严格链数（含一条空链）；区间约化 Euler 数与 Möbius 值相符。`order_polynomial(labels, strict, ...)` 计算到 `labels` 个有序标签的弱／严格保序映射数。空偏序在零标签时有一个空映射；非空偏序没有。

## 错误、资源限制与复杂度

- 通用偏序最多 256 个顶点。稠密关系和系数使用 O(n²) 存储；闭包、矩阵校验、卷积、求逆及匹配分解的主要路径为 O(n³)。不适合大型稀疏图服务。
- 所有系数均为有符号 `Int64`。加、减、乘及中间结果都检查溢出，返回 `ArithmeticOverflow`，不会环绕；即使后续可能抵消，中间溢出仍报错。
- 精确历史计数与排名采用下闭集掩码动态规划，最多 24 个顶点，最坏指数复杂度；`max_states` 限制访问的不同掩码，包含终态。
- 完整枚举采用回溯，`max_states` 限搜索节点，`max_results` 限完整结果数量；超过任一预算返回 `BudgetExceeded`，**不返回截断结果**。正预算不代表必定成功，调用方应处理异常。
- 序多项式通过下闭集多重链计算，共享预算覆盖下闭集搜索、转移对和动态规划转移；`max_ideals` 另限下闭集数。若有 I 个下闭集，预处理最坏 O(I²n²)，DP 为 O(labels·I²)。工作预算不是精确 CPU／内存配额。
- `InvalidVertex`、`Cycle`、`InvalidMatrix`、`DuplicateVertex`、`NotIdeal`、`NotExtension`、`NonUnitDiagonal`、`DimensionMismatch` 等异常区分错误来源。`is_extension` 对长度不完整的合法子集返回 false，但越界／重复顶点仍抛出异常。

不实现依赖工期调度、增量重跑、形式概念发现、证据融合、任意精度整数、任意系数环、符号多项式、随机均匀采样或定理证明。布尔格与整除序是一般模型的构造器，不能替代这些领域的专用库。

## 运行三个例子

在仓库根目录执行，示例内包含结果断言：

```sh
moon run examples/hierarchy
moon run examples/histories
moon run examples/configurations
```

分别得到聚合值 `[3,10,14,34,8]` 及恢复值；两条合法历史中排名 1 的 `[0,2,1,3]`；6 个闭合配置、可添加 `[3]`、可删除 `[1,2]` 及宽度 2。源码见 [层级聚合](examples/hierarchy/main.mbt)、[历史回放](examples/histories/main.mbt)、[配置组合](examples/configurations/main.mbt)。

## 检查与复现

```sh
moon info
moon fmt --check
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn
```

为上述 check/build/test/run 增加 `--target wasm-gc`、`--target wasm`、`--target js` 或 `--target native` 可复现各后端验证。[CI](.github/workflows/ci.yml) 在四个后端执行严格检查、构建、测试和三个例子，另检查格式和生成接口漂移。

测试共 42 项，含 152 个小型偏序输入（0 到 4 个顶点的每组正向边子集及其反向编号，部分输入产生相同偏序）。独立排列过滤、位子集和直接标签赋值与生产算法交叉核对，验证计数、排名、下闭集、分解证书、严格／弱序多项式和双侧逆。测试不是覆盖率百分比，也不是性能基准。Windows 本机已执行 wasm-gc／wasm／js；native 本机仅静态检查，实际构建／执行由 Linux CI 验证。

## 设计、许可与来源

[设计及威胁边界](docs/design.md) 说明不变量、算法和资源责任；[第三方归属](THIRD_PARTY.md)、[AI 使用说明](AI_USAGE.md) 及[更新日志](CHANGELOG.md) 随包提供。

本项目使用 [MIT](LICENSE)，独立实现数学算法，未复制 SageMath 的 GPL 源码、文档或测试。SageMath `FinitePoset`／`IncidenceAlgebra` 是能力与数学定义的参考，具体许可边界见归属文件。运行时仅依赖工具链附带的 MoonBit core。
