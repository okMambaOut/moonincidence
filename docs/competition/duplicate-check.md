# MoonIncidence 选题与语义查重

日期：2026-11-09；范围：新生态项目技术交付。比赛截止时间沿固定 Skill 记录，不重新解释；本记录不证明报名及时或官方验收通过。

## 执行方法与证据

已执行安装的 osc2026-guide 的 Project Research Guide：`moon search KEY --limit 100 --json`、MoonCakes 详情页、链接仓库源码/API/测试。使用 moon 0.1.20261016、moonc 0.10.16。检索原始 JSON、详情 HTML、GitHub 树和选读源码保留在仓库外的 `new-project-20261109/research`，不把检索命中数当作唯一性证明。

扩词包括 finite poset、partial order、偏序集、有限偏序、antichain、linear extension、order ideal、incidence algebra、IncidenceAlgebra、Mobius inversion、Möbius、order polynomial、Dilworth、count_extensions、enumerate_ideals、convolution poset、transitive reduction；另外对 TFTP、RFC1350、RTF、Rich Text Format、NBD、fixed-newstyle、libnbd 等候选执行检索。MoonCakes 包摘要存在词法噪声，逐项区分图算法、数论、数据流和实际关联代数。

GitHub 使用指定账号隔离的只读 API。仓库搜索 `poset language:MoonBit`、`"incidence algebra" language:MoonBit`、`"linear extension" language:MoonBit`、`"Mobius inversion" language:MoonBit`、`"order ideals" language:MoonBit`、`"antichain" language:MoonBit`，每页100，已返回查询 incomplete_results=false；`IncidenceAlgebra language:MoonBit` 代码反查返回0。仓库级搜索依赖元数据，代码反查覆盖也不全面，均不是绝对不存在的证明。读取官方 [awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit) 清单。读取永久注册表并完整比对 MoonConcept、MoonDag、MoonBelief 相关指纹，同时筛查 MoonCite、MoonPhone、MoonWFST、MoonContract、MoonRecur、MoonShard 等保留能力。

## 不同问题域候选排序

评分每项1—5；顺序为广度、用户多样性、复用、重合风险可控、算法深度、验证、可实现性、维护性。硬失败不由分数补偿。

|候选|成熟依据/真实任务|评分|门禁与决定|
|---|---|---|---|
|有限偏序关联代数与精确计数|SageMath FinitePoset/IncidenceAlgebra；一般层级聚合反演、合法历史计数、依赖闭合集合|4/4/5/3/5/5/4/4=34|通过；选择 MoonIncidence，限制整数环、有限规模、显式预算|
|TFTP 协议引擎|RFC1350 及 tftp-hpa；引导设备/嵌入式/网络服务间文件传输|5/5/5/1/4/5/4/4=33|直接重复，淘汰；PaiGack/tftp 已有协议与会话 API|
|RTF 文档核心|成熟 RTF 格式；文档工具、编辑器、迁移系统的解析/渲染|5/5/5/1/5/4/3/3=31|直接重复，淘汰；MoonRTF 提供解析、编码、渲染与转换|
|NBD 块设备协议|Linux NBD/libnbd；虚拟化/存储/测试后端|5/5/5/1/5/5/3/3=32|直接重复，淘汰；GitHub moon-nbd 有协商/结构化响应/后端/QEMU 互操作。moon search 未命中不能推翻源码证据|

TFTP 实际检查 [PaiGack/moonbit_tftp](https://github.com/PaiGack/moonbit_tftp) README、公共接口、完整树及 [0.1.5 文档](https://mooncakes.io/docs/PaiGack/tftp)；RTF 检查 [tlhuecdkoyg/MoonRTF](https://github.com/tlhuecdkoyg/MoonRTF) README、公共接口、parse.mbt、parse_test.mbt、树与 [0.2.0 文档](https://mooncakes.io/docs/tlhuecdkoyg/MoonRTF)。NBD 检查 [xlyyyyyy112/moon-nbd](https://github.com/xlyyyyyy112/moon-nbd) 完整文件树与协议/测试/互操作分布；没有把仅树级检查说成逐行审计。

## 核心需求与完成标准

需求依据是现有数学软件已经支持的任务，未虚构用户访谈。三类潜在使用者与可验收工作流：

1. 数据分析/数据立方体工具：输入任意有限层级关系及累计 Int64 值，构造 ζ 核，求一般区间 Möbius 逆，恢复原子贡献；重新聚合与原数据逐项一致。
2. 并发测试/事件历史工具：输入 happens-before 关系，计算合法全序历史总数，按固定字典序排名和反排名；用独立小规模排列枚举校验计数和双射。不是执行器或运行时调度器。
3. 配置/组合工具：输入依赖关系，校验和枚举向下闭合集合，计算可加入/可移除元素及格运算、分解和计数；用独立全集子集枚举校验。

稳定模型：顶点索引保持输入标识，有限偏序不可变且验证反自反循环；区间核只允许可比较端点，卷积遵守 `(a*b)(x,y)=sum(x<=z<=y) a(x,z)b(z,y)`。整数逆仅对角 ±1 存在时提供；所有系数运算检查 Int64 溢出。指数算法需要预算，耗尽显式错误；不假装截断结果为完整结果。

## 相邻能力矩阵

|相邻项目与实读证据|已有核心|与本选题关系与独立性|
|---|---|---|
|[moonbitstack/moongraph@0.1.1](https://mooncakes.io/docs/moonbitstack/moongraph)，README、dag.mbt、pkg.generated.mbti、dag_wbtest、vectors_wbtest|图接口、拓扑排序及全排序迭代、闭包/约简、部分极大反链|高度相邻；不能以闭包/排序/反链换名成新核心。本库不公开通用图规划器；一般区间系数卷积、整数单位逆、精确计数/排名及预算语义需要不可变有限关系与算术契约。把整数环逻辑加入通用图包会引入不同模型，故独立库合理|
|[Zh666-lab/moonconcept@0.1.3](https://mooncakes.io/docs/Zh666-lab/moonconcept)，README、API、lattice_ops.mbt/tests，注册表完整指纹|对象属性形式背景、Galois 闭包、概念发现、蕴含与概念格 meet/join|高度相邻数学术语；本库不发现概念/属性规则，也不重写 FCA。任意偏序上的函数反演、区间核乘法与事件历史并非形式背景接口的扩展|
|[bobzhang/differential@0.1.0](https://mooncakes.io/docs/bobzhang/differential)，README、API、frontier.mbt/tests|时间戳反链、前沿、增量数据流|同方向不同功能；反链表示前沿，不处理有限区间核和组合总数|
|[CAIMEOX/symbit@0.5.10](https://github.com/CAIMEOX/symbit)，symdiscrete API/transforms.mbt|符号卷积及 bitmask 子集/超集 Möbius 变换|高度相邻局部能力；已有布尔格变换不再声称新颖。一般任意偏序区间元素与整数单位逆不同于固定子集向量变换|
|[loop_invariants_dp@0.15.0](https://github.com/moonbit-community/loop_invariants)，sos_dp 源码、API、属性测试|2^n 向量上的 SOS ζ/Möbius 逆|同上，布尔子集特化。本库布尔格仅为通用模型测试/示例，不以该特化作为选题|
|[moon-certified@0.1.1](https://github.com/Juwan-Hwang/moon-certified)，树、number_theory/mobius 源码/测试|整数约数的 μ(n)、筛法与数论反演|同方向不同功能；不是任意有限偏序关联代数。检索中 enumerate_ideals 为模块级噪声，相关树未见有限偏序实现|
|[bobzhang/bap@0.4.0](https://mooncakes.io/docs/bobzhang/bap)，README、树、选定 API|二进制分析、反汇编、IR/图|无实质直接重合；incidence 词命中不能当成数学包|
|MoonDag/MoonFlowGraph 注册表与 MoonDag README|执行计划、CPM 工期/松弛、变更影响/重跑|禁止侵入其保留能力；本库不含任务执行、时间估计或影响规划|
|MoonBelief 注册表完整指纹|焦元质量、冲突再分配、证据融合、子集变换|不做信念质量或决策；只共享数学中特化 ζ 术语|

## 来源、实现边界与限制

[SageMath IncidenceAlgebra](https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/posets/incidence_algebras.html) 和 [FinitePoset](https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/posets/posets.html) 为成熟行为对标；核对其源码头部版权和 COPYING：原 Sage 库 GPL-2.0-or-later，整体发行 GPLv3，文档 CC-BY-SA。MoonIncidence 是独立 MIT 数学算法实现，不搬运 Sage 源码、文档段落或测试夹具，不宣称兼容 Sage 的任意系数环/无限精度/完整 API。使用自编数学向量与独立穷举验证。

匿名 GitHub API 触发限流后改用已绑定账号的只读 API，没有换号；部分 raw.githubusercontent.com 请求重置后改 contents API，失败的请求未记作成功阅读。MoonCakes 页面/API均保存可读证据；不按下载量推断算法质量。未穷尽所有私有/未索引仓库、语言未标注的源文件和搜索排序外结果。交付前需反查关键接口并复核新增注册记录。

## 发布前反向复核（2026-11-09）

重新以 incidence、convolution poset、order polynomial、Dilworth、count_extensions、enumerate_ideals、IncidenceAlgebra、Möbius 检索 MoonCakes，并复核新增数学命中；本次检索原始证据另存，不覆盖初次选题材料。

| 新增相邻项目 | 实际阅读范围与边界 |
|---|---|
| `ky678/renky@0.1.3` | 下载精确发布源包，阅读 README、omniring/arith 公共接口、div.mbt 和 laws_wbtest.mbt；μ 是素因子定义的整数数论函数。另读 omniring/ideal 公共接口，其中 ideal 为多项式／有限域理想与 Gröbner 商空间，并非偏序下闭集。全源检索未见一般偏序区间卷积、Dilworth 或历史排名接口。包未提供可验证的同名 GitHub 仓库，不将 404 当作源代码缺失证明。 |
| `bobzhang/loop_invariants_math@0.17.0` | 下载精确发布源包，阅读 mobius 公共接口、实现与性质测试；公开 mu(Int64) 和 sieve(Int)，属于整数约数 μ(n) 与筛法，没有任意偏序区间核模型。关联仓库 moonbit-community/loop_invariants。 |
| `bobzhang/hol_light@0.1.0` | 阅读 bobzhang/hol-light.mbt README 与完整树；定位为形式定理证明器，属于搜索术语噪声。本次未作其完整源码／测试审计，不据此作更强结论。 |

未出现需要改变选题或收缩已交付 API 的直接替代。比较仍以任意有限偏序模型、整数区间卷积／求逆和预算化精确组合工作流为单位，不以单个数学术语或包名判定。

**结论：在已记录检索范围内未发现成熟直接替代。** 这不是生态绝对唯一性或官方认可证明。
