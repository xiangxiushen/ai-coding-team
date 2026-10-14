---
name: review-checklist
description: 评审视角清单单一真源：各轴触发条件 + 检查项 + severity 分级（Reviewer/QA 用）。
---

# 评审清单（Review Checklist）— 单一真源

> 本 skill 是**贡献者自查与 Reviewer 评审对照的同一份清单**。其他 skill 只引用本 skill 的对应视角，**不另写一套**。
> 改评审项在这里改，全队自动对齐。原为仓库规范，现作为可执行 skill 挂 Reviewer / QA。

## 是什么 / 何时用

把「一个 MR 该从哪些视角审、每个视角查什么」固化成清单，避免评审凭感觉、漏视角。

**用**：Reviewer 出评审结论时逐视角对照；QA 做验收时看「正确性 / UI / PRD 一致性」轴；治理类改动的评审。

**不用**：不替代各专门 skill 的方法论（安全查 `security-and-hardening`、性能查 `performance-optimization`）；本 skill 是**视角索引 + 检查项**。

## 评审视角总览

| 视角 | 触发条件 | 谁执行 | 对应 skill |
|---|---|---|---|
| 基础（正确/可读/架构/安全/性能） | 所有 MR | Reviewer | `code-review-and-quality` |
| 架构视角 | 架构契约 / ADR / 系统设计（组件/部署/数据流/存储/集成边界） | Reviewer | `architecture-reviewer` |
| DBA 视角 | 动了 DB schema / migration / 索引 / 数据模型 | Reviewer | `dba-schema-review` |
| 安全轴 | 鉴权 / 密钥 / 信任面 / 输入边界 | Reviewer | `security-and-hardening` |
| 性能轴 | 热路径 / 列表接口 / 批量操作 | Reviewer | `performance-optimization` |
| UI 设计还原度轴 | 变更含 UI / 前端页面 / 组件 | Reviewer | `ui-design-review` |
| PRD 一致性轴 | 变更涉及需求行为 / 范围 / AC | Reviewer | `prd-management` |

## 一、正确性（P0，最高优先）

- 与最新版 `PRD.md` 一致吗？行为 / 范围 / AC 是否相符？不符时，是代码错还是 PRD 需回流更新？
- 符合 spec 吗？边界（null / 空 / 边界值）处理了吗？
- 错误路径（不只 happy path）覆盖了吗？
- 有无 off-by-one、竞态、状态不一致？
- 测试真在测该测的吗？

## 二、可读性与简洁性（P1）

- 命名描述性且一致？控制流直接？
- 有无「聪明」技巧该简化？能否用更少的行？
- 抽象配得上复杂度吗（不到第三个用例别泛化）？
- 有无死代码、空实现、占位符残留？

## 三、架构（P1）

- 遵循既有模式还是引入新模式？模块边界干净？
- 有无循环依赖？抽象层级恰当？
- 这个重构是降复杂度还是挪地方？
- **架构视角（命中触发时，对照 `architecture-reviewer`）**：组件 / 部署 / 数据流 / 存储 / 集成边界改动是否含 mermaid 拓扑图？契约是否冻结且与 PRD 一致？NFR 是否有明确目标（性能 / 可用性 / 可扩展 / 可观测 / 可维护）+ 灰度 / 回滚？ADR 编号唯一、四段齐全？每个受影响 FR 是否映射到具体模块？是否脱离业务规模过度设计？

## 四、安全（P0，涉及信任面必过）

- 输入校验 / 清洗？密钥进代码 / 日志 / 版本控制？
- 认证授权到位？SQL 参数化？输出编码防 XSS？
- 依赖可信无已知漏洞？
- **fail-closed 检查**：缺依赖 / 缺配置时的失败姿态必须默认拒绝。

## 五、性能（P1，涉及热路径必过）

- 有无 N+1 查询？无界循环 / 无约束抓取？
- 该异步却同步？列表接口分页？热路径大对象创建？

## 五·A、DBA 视角（涉及 DB schema / 数据模型时必过）

命中「动了 DB schema / migration / 索引 / 数据模型」时叠加，**完整 12 条清单见 skill `dba-schema-review`**。要点：

- 新表是否落在本域 schema（不进 `public` 裸放）？跨域是否只按 ID 松引用？
- 枚举是否用 `text + CHECK`？时间列是否 `timestamptz` + `_at`？主键是否 UUIDv7？
- 软删是否统一 `deleted_at`？不变量是否由约束保证？
- 索引是否对齐查询模式？建表前是否查重（含单复数变体）？跨仓所有权是否确认（一个实体一个 owner 仓）？

## 六、治理视角（改规则/流程/标准时必过）

命中 skill `merge-gate-matrix` 「小队规则 / 标准 / agent 定义 / 流程」行的 MR，额外过：

- 是否显式标「待人类批准」？
- 是否有 post-merge 应用清单（同步命令 + 冒烟步骤）？
- 批准集是否逐项登记（approve / request changes / 弃权）？
- **两节点共识 + 人类拍板**，不能拿 agent 评审自证生效。

## 七、沟通与写作（所有 MR）

- 结论先行？一句话 ≤50 字？要点 ≤6 条？
- 半角标点 / 朴素用词 / 无 AI 腔？（见 skill `communication-and-writing`）
- 引用可回查？断言范围 = 验证范围？（见 skill `mr-four-part-checklist`）

## Severity 分级（Reviewer 必标）

| 前缀 | 含义 | 作者动作 |
|---|---|---|
| **Critical:** | 阻断合并 | 安全漏洞、数据丢失、功能损坏，必改 |
| *(无前缀)* | 必须改 | 合并前处理 |
| **Nit:** | 轻微可选 | 格式 / 风格，可忽略 |
| **Optional:** | 建议 | 值得考虑不强制 |
| **FYI** | 仅信息 | 无需动作 |

## 完成判据（本 skill 视为已遵守）

- [ ] 命中触发的视角**一项不漏**（按「评审视角总览」逐项对照，含架构 / DBA 条件轴）；
- [ ] 每条意见标了 severity（Critical / 无前缀 / Nit / Optional / FYI）；
- [ ] 治理类改动额外过了第六节四项；
- [ ] 结论直接指向对应真源 skill，未另写一套标准；
- [ ] 汇总前已过 **`fact-check-protocol` 事实核查复检**（删除的发现均引用了具体 diff 行）。
