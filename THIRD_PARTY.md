# 第三方归属与实现来源

MoonIncidence 为独立编写的 MIT 实现，不是 GPL 代码移植。

| 来源 | 使用方式及许可边界 |
| --- | --- |
| MoonBit core，https://github.com/moonbitlang/core | 工具链提供的标准库与 debug 接口；Apache-2.0（仓库附带运行时链接例外，以其原许可证为准）。未复制其源码进入本仓库。 |
| SageMath，https://github.com/sagemath/sage；https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/posets/posets.html；https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/posets/incidence_algebras.html | 用于确认成熟生态的有限偏序、关联代数及 Möbius 定义和能力边界。Sage 库相关实现采用 GPL-2.0-or-later，整体发行说明采用 GPLv3，文档为 CC-BY-SA。没有复制源码、测试向量或文档表达；未链接或打包 Sage。 |

数学构造包括传递闭包、关联代数卷积、Möbius 递推、下闭集动态规划和 Dilworth 匹配分解，均根据定义独立实现。测试数据由本仓库手写或直接穷举产生。未引入第三方静态数据集、生成代码或来源不明片段。当前不声称与 Sage 的任意系数环、有理数或符号功能兼容。
