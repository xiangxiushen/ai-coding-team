---
name: team-canon
description: "团队通用底座: 全 agent 共享的铁律 + 真源索引(功能清单/共享件/标准/经验规则/agent即代码)。只放指针不复制内容。新建 agent 默认挂载以继承团队知识。"
status: active
---

# team-canon — SC-SDLC 团队通用底座 (所有 agent 必读)

全团队 agent 共享的最小底座: 铁律 + 真源索引。只放"指针"和最高频铁律, 不复制内容(内容以真源为准, 避免漂移)。@Librarian 保持其新鲜。

## 铁律 (所有 agent 通用)
- master = 定稿真源; 开了 MR = 进入评审; 一切改动走 MR + @Critic 评审, 不手写状态。
- **feat 交付**: 更新 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/feature-inventory.md`(功能清单持续校准同一份) + 含关键/非显然逻辑写 `docs/impl/<域>/<功能>.md`; **动手前先查 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/shared-components.md` 复用, 不重造轮子**。
- MR 标题带 `type(scope):` + `(SCAI-xxxx)`; feat 描述带 `PRD: prd/<文件>.md` 引用。
- 文风: 半角标点后带空格、朴素、无 AI 腔、面向同事。
- **评论区精简 (所有 agent)**: issue 评论区 与 GitLab(MR)评论区 的每条回复一律精简、重点突出 —— 结论先行(结论 + 一句话 ≤50 字 + 要点 ≤6 条) + 证据(文件:行 / 端点 / 链接); 短句列表, 不铺陈、不复述、结论不埋末尾。一条一动作; 通过类只留"评审通过, 待合并"。细则与模板见 `standards/review-checklist.md §8.1`。
- 只读/只提案的角色(如 Critic/Librarian)绝不越权改代码/标准/别的 agent。
- 帮别人域写的活用自己账号提交(或 Co-authored-by), 让贡献如实体现。
- **建/改模块更新其用法文档** `architecture/contracts/<module>-module.md`; **跨模块开工前读目标 -module.md + https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/standards/linking.md**(引用人/照片/帖子/俱乐部 + 承接 URL 唯一真源; 引用人只走 normalizeToSub, 失败必 404)。

## 精简回复模板 (issue / MR 通用, 直接复制)
```
结论: <通过 / 要求修改 / 需要其他角色 / 升级 / 已交付 / 有阻塞>
一句话: <≤50 字, 核心判断>
要点:
- <≤6 条, 每条一句, 一条一动作>
证据: <文件:行 / 命令 / 端点 / MR / issue 链接>
```
- 只有抬头 + 证据是必需的; 详情按需, 折叠或后置, 不得与抬头矛盾。
- 通过 / 完成类只留一句结论, 不复述 diff、不写铺垫。

## 人的闸门与机读判定 (所有 agent; 全文见 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/standards/human-gates.md, 本节自带可用的最小副本)
- **只有三类事需要人**: G-PROD 生产发布 / G-SEC 安全红线(红线路径、鉴权与 secret、数据库迁移、部署编排、CI 配置、治理类提案、`standards/` 与 agent/skill 定义) / G-ESC 升级(同一 MR 第 3 次评审仍"要求修改"、同一步连续失败 2 次、24 小时无进展、超预算)。其余步骤(PRD 定稿、设计/代码/用例/mockup 评审、验收、非红线 MR 合并、关单)全部由 agent 判定, **不要问发起人"能否关单/能否合并"**。
- **合并权**: PRD → PM; 架构/ADR/数据设计 → Architect; 其余非红线(代码、用例、mockup、文档) → Conductor(定稿代理)。前提: Critic(及要求的专家票)对**当前 sha** `approve`、CI 绿、无冲突、无 P0/P1。
- **机读判定**: 每个评审/验收/合并闸门, 在 issue 评论末尾放一个 ```json 代码块, 并写 issue metadata(`multica issue metadata set <issue-id> --key verdict_<gate> --value '<单行 JSON>'`; 写法不确定先 `--help`):
```json
{"schema": "agent-verdict/1", "gate": "code-review", "decision": "approve",
 "round": 1, "subject": {"mr": "<MR 链接或 iid>", "sha": "<被评审 sha>"},
 "blockers": [], "evidence": ["<命令输出摘要 / 报告 / 链接>"],
 "reviewer": "<你的角色名>", "timestamp": "<UTC RFC3339>"}
```
  `gate` ∈ prd-review / design-review / testcase-review / code-review / mockup-review / acceptance / merge / release-plan / test-data; `decision` ∈ approve / changes_requested / escalate / skip(仅条件阶段跳过留痕); `blockers` 形如 `[{"sev":"P0","text":"..."}]`, `approve` 时不得含 P0/P1; 无证据不得 `approve`; 判定只对该 sha 有效; 评审类判定由非作者出具。

## 跨小队交接与出口 (所有 agent; 全文见 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/standards/squad-handoff.md, 本节自带可用的最小副本)
- **流程**: 一条需求依次经 产品方案小队 → 产品实现小队 → 产品验收小队, 三个小队各自以小队身份运行、各自留机读判定; **不得跳过下游小队, 不得把多个阶段并成一份判定**。
- **交接 = 建子单并指派给下一个小队**, 只在评论里 @ 另一小队的个别 agent 不算交接: `multica issue create --title "<标题>" --parent <root-id> --stage <1|2> --assignee "<下一个小队名>" --status todo --description-file <摘要文件>`; 已有子单用 `multica issue assign <child-id> --to "<小队名>"`。
- **`squad-handoff/1` 记录**(交出方队长写, 三处落地): 根单评论 JSON 块 + 根单 metadata `handoff_<seq>`(1=方案→实现, 2=实现→验收) + 目标子单 metadata `handoff_in`。字段: `schema, seq, from_squad, to_squad, root_issue, source_issue, target_issue, stage, artifacts[{kind,mr,sha}], verdict_refs, timestamp, created_by`。
- **入口门**: 接收队长开工前必须读到 `handoff_in` 且其 MR 为 `merged`; 缺失 → 评论 `BLOCKED: no squad-handoff/1` 并 @ 交出方队长, 不得开工、不得自行补写。
- **关单权**: 只有产品验收小队队长, 在 Reporter 报告发出(评论含 `SENT ok` / `dry-run`)且 `scripts/squad_flow_audit.py` 退出码 0 之后, 才能关**根需求单**; 方案 / 实现小队队长不得关根单。
- **条件阶段**(PM 阶段 0 写根单 metadata `flow_plan` = `flow-plan/1`: `ui_scope`, `test_data_required`): 涉及任何网页 / 屏幕 → `ui_scope=true` → Mockup-design 出 mockup、Mockup-critic 评审(`mockup-review`)、验收时 Mockup-design 高保真 UI 验收, 均强制; 验收需预置数据 → `test_data_required=true` → 造数官强制; **Reporter 报告始终强制**。跳过只能用 `agent-verdict/1` 的 `decision: "skip"` + `reason` + 非作者 `approved_by`, 且触发条件为 `false`; `ui_scope=true` 时 skip 无效。

## 真源索引 (需要时去读, 别复制到别处)
- **规范与 runbook 的读取位置（渲染后的发布副本，钉版本）**: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/standards/ · https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/runbooks/ · https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/project-pack/ (docs 仓 `kit/` 目录; 版本见其中 `MANIFEST.json`; 下文 `standards/…` 都指这里)
- 标准: `standards/`(coding-backend/frontend, git, contribution, api, db-standard, mr-traceability, prd-change-management, learnings…)
- 架构决策: `docs/architecture/adr/`; 决策台账: `docs/decisions/`
- 功能清单: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/feature-inventory.md`; 共享件登记: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/shared-components.md`; 模块盘点: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/module-status.md`
- 经验规则(防重复踩坑): https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/standards/learnings.md
- 传播不漂移: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/sources-of-truth.md`; agent 即代码: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/README-agent-team-as-code.md`; 编排: https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `ops/orchestration-playbook.md`
<!-- kit:sha256=de86cf5bf4b2463e -->
