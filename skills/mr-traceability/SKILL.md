---
name: mr-traceability
description: PRD ↔ MR 溯源三层闸门：L1 机械/L2 语义/L3 台账 + PRD 引用格式 + 关联单号 + PRD 先行铁律（TechLead/Dev/Architect 用）。
---

# MR 需求溯源（MR Traceability）

> 让**每个新功能都能追到 PRD**，防止「无依据实现」和「把未定稿的开放问题先写成代码」。
> **PRD 先行、代码在后**；把功能伪装成 `fix` 绕过溯源 = **红线**。
> 借鉴 mitabase `mr-traceability`，适配本小队 `docs/prd/` 真源。挂 TechLead（建 MR）+ Dev（提分支）。

## 是什么 / 何时用

把「一个 MR 该带哪些溯源锚点、谁来机械查、谁来语义查」固化成**三层闸门**。

**用**：Dev 提交分支前 / TechLead 建 MR 前逐条核对；评审前 L1 机械检查。
**不用**：PRD 自身的内容质量（走 `prd-critic`）、代码质量（走 `code-review-and-quality`）。

## 一、分类与要求（按 MR 标题前缀）

| 前缀 | 含义 | 溯源要求 |
|---|---|---|
| `feat` | 新功能 / 新端点 / 新 UI 能力 | **必须**在 MR 描述写 PRD 引用（格式见第二节） |
| `fix` / `refactor` / `test` / `chore` / `docs` | 修复 / 重构 / 测试 / 杂务 / 文档 | 免 PRD，但描述必须写清动机与背景，**空描述打回** |
| `hotfix` | 线上 / staging 紧急修复 | 可先合，合并后 24h 内补齐描述 |

标题必须以 conventional 前缀之一开头（如 `feat(gallery): ...`）。

## 二、PRD 引用格式

MR 描述中**单独一行**：

```
PRD: docs/prd/<需求id>/PRD.md § FR-x.y
```

- 可引用多条：`PRD: docs/prd/<需求id>/PRD.md § FR-3.1, FR-3.2`
- 文件必须真实存在于 `docs/prd/`（master）；FR 编号必须在该 PRD 中**真实存在**。
- 确无对应 PRD 又确属 `feat` → **先补 PRD**（见第四节），不接受 `PRD: N/A` 的 feat。

## 三、三层闸门（谁来查）

| 层 | 执行者 | 查什么 |
|---|---|---|
| **L1 机械**（零 LLM） | TechLead 建 MR 前 / 评审前 | 标题前缀合规；`feat` 描述含 `PRD: docs/prd/...` 且文件在 master 存在、FR 编号真实；非 `feat` 描述非空；代码仓 `feat` / `fix` 的**标题或描述必须含关联单号**（Multica issue 编号，形如 `SCDE-\d+`）；以及 **MR 目标分支由人类明确提供且可回查（agent 自选 target 即打回）**。不满足 → 直接判「要求修改」，**不进入评审** |
| **L2 语义** | Reviewer | FR 编号真实存在；diff 范围与 FR 范围一致；未实现 PRD 标为「开放问题 / 下一阶段 / 待确认」的内容；与 PRD 冲突时**以 PRD 为准或先改 PRD** |
| **L3 台账** | TechLead | 合并的 `feat` MR 记 `prd` 字段；周期性输出「FR → 实现覆盖清单」与「**无 FR 的实现**清单」 |

**Driver 归因**：agent 代人发起的 MR / issue，描述中**单独一行**写驱动者 `Driver: @<人名>`（人自己提的不用写）。统计侧归因优先级：`Driver:` 标记 > issue 人类创建者 > MR 人类作者。

## 四、上游规则：PRD 先行

没有 PRD 依据的新功能，流程是：

1. 开 issue 描述需求，指派 Product；
2. Product 提 PRD MR（`docs/prd/`），人类确认 + 过 `prd-critic`；
3. PRD 定稿后再开代码 MR，引用新 FR 编号。

**把功能伪装成 `fix` 绕过溯源 = 红线**，评审发现直接打回。

## 五、豁免

- `hotfix`：事后补，不阻塞；
- 纯依赖升级 / CI 配置 / 格式化（`chore`）：免 PRD；
- PRD 自身的 MR：不适用本节，走 `prd-critic` + 人类确认。

## 六、与四段自检的关系

本 skill 与 `mr-four-part-checklist` **互补**：四段自检管「描述写全了没」，本 skill 管「功能能追到需求没」。

- 四段自检的**第 3 段「引用可回查」**，其 PRD 引用格式与关联单号要求**以本 skill 为准**。
- 建 MR 前：先过本 skill 的三层闸门（L1），再过四段自检。

## 反面案例

- 新增 `GET /xxx` 端点、描述为空 → 属 `feat` 无溯源，**L1 即打回**。
- 正面对照：`feat(gallery): 感知哈希去重 (FR-3.1/3.2/3.3)` + 描述含 `PRD: docs/prd/SCDE-000/gallery.md § FR-3.1` + `(SCDE-000)`。

## 完成判据（本 skill 视为已遵守）

- [ ] 标题前缀合规；`feat` 已写 PRD 引用且文件 / FR 编号可回查；
- [ ] 非 `feat` 描述非空；代码仓 `feat` / `fix` 含关联单号；
- [ ] MR 目标分支由人类提供且可回查（未自选 target）；
- [ ] 未把功能伪装成 `fix` 绕过溯源；
- [ ] agent 发起的 MR 已写 `Driver:` 行；
- [ ] L3 台账的「无 FR 的实现」清单已周期性输出。
