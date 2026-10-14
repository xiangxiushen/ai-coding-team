# 开发小队 · Dev Squad

> 通用开发小队：从**技术需求**到**代码交付**——PRD → 架构/规格 → TDD 实现 → 测试 → 五轴评审 → 交付。
> 6 个 agent + 1 个 squad + 29 个 skill，可**一键安装**到 Multica 工作区，或把 skills 复制进任意 AI 编码工具。

## 概览

- **谁**：1 个 Leader（TechLead）+ 5 个专才（Product / Architect / Dev / QA / Reviewer）。
- **做什么**：一条清晰链路——*谁、什么阶段、产出什么、以什么标准通过*——外加一套「对账优先」的编排闭环。
- **怎么保证质量**：每个阶段都有产物与门禁，产物是 Git 上真实存在的 MR，验证必须有证据。
- **交付物形态**：agent 是平台原生的「agent-as-code」JSON 规格；skill 是标准的 `SKILL.md` 能力包。

## 交付流程（S0–S6，严格串行 + 变更回流）

```
S0 需求与设计 → S1 受理拆解 → S2 架构与规格 → S3 实现 → S4 测试 → S5 评审 → S6 交付
      ↑                                                                        │
      └──────────────────── 变更回流（需求变更，须人类确认）────────────────────┘
```

| 阶段 | 执行者 | 产物 | 门禁 |
|---|---|---|---|
| S0 | Product | `PRD.md` + 含 UI 时 mockup | `prd-critic` 挑刺通过 + **人类确认** |
| S1 | Leader | 任务清单（原子任务 + 依赖序） | 人类确认范围 |
| S2 | Architect → Dev | `architecture-design.md` + ADR/契约；`spec.md` | 人类 approve 设计 + spec |
| S3 | Dev | 代码 + 单测（runtime 执行，附证据） | 单测全绿 + 自审 + 执行证据 |
| S4 | QA | `qa-report.md`（AC 证据映射）+ 签核 | AC 映射全过 + 通过率硬门 + P0/P1 回归 100% |
| S5 | Reviewer | 多轴评审结论 + 事实核查复检 | Critical 清零 + 事实核查完成 |
| S6 | Leader | MR（过 L1 溯源检查）+ 交付记录 | **人类 merge** |

> 门禁未过不推进。**agent 绝不 merge**——MR 一律由人类合并。

## 花名册

| Agent | 角色 | 挂载 skill |
|---|---|---|
| **DevSquad-TechLead** | Leader · 编排与门禁 | 8 |
| **DevSquad-Product** | 需求受理 · PRD · mockup | 6 |
| **DevSquad-Architect** | 技术设计 · 契约 · ADR · 数据模型 | 8 |
| **DevSquad-Dev** | 规格 · TDD 实现 · 修 bug · 自审 | 13 |
| **DevSquad-QA** | 测试策略 · 用例 · 执行 · 签核 | 9 |
| **DevSquad-Reviewer** | 多轴评审 · 事实核查 · PRD 挑刺 | 13 |

**小队**：`开发小队`（leader = `DevSquad-TechLead`，共 6 名成员）。

## 协作模型（一句话版）

- **对账优先**：Leader 每次被唤醒都扫一遍所有未完成子任务，把每个卡住的推到唯一下一步；事件只是加速。
- **幂等**：派活前先查该任务是否已在飞或已完成，绝不重复派、不把同一产物派给多人。
- **终态**：门禁一过即收口，绝不让任务停在「完成但没收口」。
- **派活铁律**：唤起成员必须用完整 mention 链接 `[@名字](mention://agent/<uuid>)`；纯文本 `@名字` 不触发。
- **反循环护栏**：同一产物满 2 个来回（第 3 次仍要求改）→ 不再踢回，升级人类带可裁决摘要。
- **上抛人类**：门禁累计 3 次失败 / 疑似安全问题 / 需求边界需裁定 → 加 `Need:Human` 并点名到人。

完整协作规则见 [`squad/dev-squad.md`](squad/dev-squad.md)。

## 能力清单（29 个 skill）

| Skill | 说明 |
|---|---|
| `arch-design` | @Architect 怎么给 SC-SDLC 做技术设计与架构设计: MCP-first 契约优先、ADR 落定、NFR 对照、分期切片。产出写进 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `architecture/adr/` 与 `architecture/contracts/`, 走 MR。自评口径引用 `standards/review-checklist.md` … |
| `architecture-reviewer` | @Critic 评架构概要设计 / 架构文档时的薄评审视角: 逐条对照 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/powerjob/standards/review-checklist.md §4 架构视角, 不另带清单。 |
| `code-review-and-quality` | 五轴评审 + severity 分级 + 诚实评审 + 依赖审查（Reviewer 用）。 |
| `communication-and-writing` | 沟通精简（结论先行/挑重点/带证据）+ 写作规范（朴素/无 AI 腔）+ @mention 唤起格式（全队挂载）。 |
| `dba-schema-review` | DBA / 数据库设计评审视角(通用): 对建表 / 改数据模型的 MR 审 schema 归属唯一 owner、建表前查重、约束保不变量、索引对齐查询、迁移可回滚与在线性; 引擎相关条款按 project.db.* 配置启用。挂 Architect(产出)+ Critic(评审)。 |
| `debugging-and-error-recovery` | 五步 triage 系统化定位根因 + 加护栏防复发（Dev 修 bug 用）。 |
| `defect-management` | 缺陷全生命周期：登记规范 + P0-P3 定级与 SLA + 关闭规则 + 复盘触发 + 度量目标（逃逸率/P0P1 回归 100%）（QA 用，缺陷治理单一真源）。 |
| `fact-check-protocol` | 评审后事实核查复检：删掉 diff 能证明为假的发现，默认全保留（不对称原则）+ 保护性主题否决 + Ground A/B（Reviewer 用）。 |
| `frontend-ui-engineering` | 生产级前端实现：组件架构、设计系统对齐、全状态、响应式、可访问性（Dev 做 UI 用）。 |
| `git-workflow-and-versioning` | 原子提交、commit 规范、变更尺寸、主干开发（Dev 提交用）。 |
| `gitlab-workflow` | 对接 MCD GitLab 的读代码/提交/MR 流程：走 GitLab MCP 工具，分支从 release 切、MR 目标由人类给定，agent 绝不 merge（Dev 用）。 |
| `incremental-implementation` | 薄纵向切片交付，范围纪律，特性开关，可回滚（Dev 实现用）。 |
| `learnings` | 经验规则台账（learnings/LEARNINGS.md）：一条一行+带证据+按域分类，评审/复盘后提炼规则；TechLead 兼维护。 |
| `merge-gate-matrix` | 「变更类型 -> 过什么门 -> 谁合并」单一真源 + 6 条铁律 + S4 门构成 + 分支策略（全队挂载）。 |
| `mockup-design` | 把 PRD/spec 变成可评审的 mockup：需求覆盖、设计系统对齐、全状态、响应式、可访问性（Product 用）。 |
| `mr-four-part-checklist` | MR 四段自检：根因单 / 口径同步清单 / 引用可回查 / 安全 fail-closed 声明 + 断言范围=验证范围红线（TechLead/Dev 用）。 |
| `mr-traceability` | PRD ↔ MR 溯源三层闸门：L1 机械/L2 语义/L3 台账 + PRD 引用格式 + 关联单号 + PRD 先行铁律（TechLead/Dev/Architect 用）。 |
| `performance-optimization` | 独立性能审计 persona：N+1/无界抓取/索引/缓存/重渲染（Reviewer 性能轴用）。 |
| `planning-and-task-breakdown` | 把工作拆成小、可验证、带验收标准的原子任务，按依赖排序并设检查点（TechLead 拆解用）。 |
| `prd-critic` | 对一份 SC-SDLC 域 PRD 跑质量+完备+合规+文风 checklist, 输出点名到具体条目的修复建议。只评不改。任一 P0 未过 → 最高 ⚠️待修 / status=changes-requested。由 @Critic 引用。 |
| `prd-management` | 把需求变成可评审、可追溯的 PRD（六段结构 + 变更日志），作为唯一需求真源；变更必须人类确认（Product 用）。 |
| `review-checklist` | 评审视角清单单一真源：各轴触发条件 + 检查项 + severity 分级（Reviewer/QA 用）。 |
| `security-and-hardening` | 独立安全审计 persona：注入/XSS/SSRF/密钥/供应链/LLM（Reviewer 安全轴用）。 |
| `security-redlines` | 安全红线五条：凭据绝不入库 / 绝不编造 URL / fail-closed / 绝不 merge / 不确定上抛（全队挂载）。 |
| `spec-driven-development` | 先写规格（六要素 + 假设显式化）经人类 approve 再写代码（Dev 规格用）。 |
| `team-canon` | 团队通用底座: 全 agent 共享的铁律 + 真源索引(功能清单/共享件/标准/经验规则/agent即代码)。只放指针不复制内容。新建 agent 默认挂载以继承团队知识。 |
| `test-driven-development` | 红绿重构 + 测试金字塔 + Prove-It 修 bug + 测行为不测实现（Dev/QA 共用）。 |
| `test-strategy-and-execution` | 测试策略 + 用例三件套 + AC 证据映射 + 通过率硬门 + P0/P1 回归 100% + 误判复核 + 签核（QA 用；S4 不复跑单测，做证据审查与补强）。 |
| `ui-design-review` | 当你需要做Mockup评审，审查设计稿是否覆盖 PRD 需求，或对比设计稿与前端实现的视觉还原度时使用此 Skill |

## 一键安装

### 方式 A — AI 一键安装（推荐）

把下面这句话丢给你的 AI 编码助手（Multica / Claude Code / opencode）：

```text
把这个仓库安装到我的 Multica 工作区：
https://github.com/xiangxiushen/ai-coding-team
按仓库里的 install.sh 执行，装完告诉我装了哪些 agent 和 skill。
```

### 方式 B — 命令行一键装

```bash
git clone https://github.com/xiangxiushen/ai-coding-team.git
cd ai-coding-team

./install.sh                     # 自动探测：有 multica 就装 Multica，否则装 opencode 技能
./install.sh --target multica    # 装进当前登录的 Multica 工作区
./install.sh --target opencode   # 只把 skills/ 复制到 ./.opencode/skills
./install.sh --dry-run           # 先看会执行哪些命令
```

安装器是**幂等**的：已存在的 skill / agent / squad 默认跳过，加 `--force` 才会重建。

### 方式 C — 逐条导入 skill（Multica）

```bash
multica skill import --url https://github.com/xiangxiushen/ai-coding-team/tree/main/skills/merge-gate-matrix
```

## 仓库结构

```
ai-coding-team/
├── README.md              # 本文件（介绍）
├── install.sh             # 一键安装器
├── manifest.json          # 清单：agents / skills / squad
├── agents/                # 6 个 agent
│   ├── DevSquad-TechLead.json   # 平台原生规格（agent-as-code，可直接重建）
│   ├── DevSquad-TechLead.md     # 可读版（frontmatter + instructions）
│   └── ...                      # Product / Architect / Dev / QA / Reviewer
├── squad/
│   ├── dev-squad.json     # 小队定义 + 成员与角色
│   └── dev-squad.md       # 协作规则全文
└── skills/                # 29 个能力包
    ├── index.json         # skill 名称与说明索引
    ├── merge-gate-matrix/SKILL.md
    └── ...
```

## 来源与再生成

本仓库由 Multica 工作区 **SC-SDLC** 的「开发小队」导出：agent 取自平台 `agent get` 的 agent-as-code JSON 规格，skill 取自平台 skill 内容。
`agents/*.json` 就是 agent 的真源：字段齐全（name / description / instructions / model / skills / 权限），改完可直接用 `multica agent create` 重建。

> 注意：部分 skill 正文引用了团队内部地址（如 `gitlab-ex.mcd.com.cn` 上的 `standards/*`）作为**指针**；
> 在团队外使用时，这些内部地址不可达，请按 skill 内说明替换为你自己的标准真源。

