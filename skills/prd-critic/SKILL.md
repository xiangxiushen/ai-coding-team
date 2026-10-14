---
name: prd-critic
description: "对一份 SC-SDLC 域 PRD 跑质量+完备+合规+文风 checklist, 输出点名到具体条目的修复建议。只评不改。任一 P0 未过 → 最高 ⚠️待修 / status=changes-requested。由 @Critic 引用。"
---

# prd-critic

挑刺的, 不是润色的。只评审、只给点名到具体条目的修复建议, 绝不替 @PM 写 PRD 正文、绝不改正文。

> 规则集中在这一个文件, 改评判规则只改这里。图标对红绿色弱友好: 靠**形状+文字**区分, 不靠颜色。

## Checklist(逐条 pass/fail, 标严重度 P0拦截 / P1强烈建议 / P2建议)

**C1 结构完整**
- 八段齐(背景目标/用户场景/功能需求/MCP tool 草案/Non-Goals/成功指标/依赖开放问题/元数据)— P1
- 无占位符(TODO/待补充/xx/"更好"等)— **P0**
- 元数据行 + status 有 — P2

**C2 需求质量**
- 功能条目是**具体行为**, 不是理念口号 — P1
- 每条有优先级 P0/P1/P2 — P1
- 用户故事是真实场景(作为…要…以便…), 非虚构 — P1
- 不把 Phase 2/3 的东西塞进 v1 范围 — P1

**C3 MCP-first(硬)**
- 每个功能域有对应 MCP tool 草案(名字+用途+读/写)— **P0**(概念 P1 原则, 无 tool = 拦)
- tool 草案与 concept §8 目录不冲突 — P1

**C4 Non-Goals 与边界**
- Non-Goals(v1)明确列出、可冻结 — **P0**(G1 退出标准)
- 与相邻域无重复认领 / 无边界打架 — P1

**C5 指标可测**
- 每条成功指标中立的人能客观判定"达成/没达成" — **P0**(不能"提升体验""加强治理"这种)
- 指标对得上一条闸门退出标准 — P1

**C6 合规红线(硬, 不可妥协)**
- Impressions approve-first(被贴者主权/永不进 HR)原样承接 — **P0**(若涉 People)
- 肖像权/知情同意/takedown、人脸 PIPL 单独同意 v1 人工圈选 — **P0**(若涉 Gallery)
- 隐私字段级控制 + 被动方否决权 — P1

**C7 文风 + 自洽**
- 无虚大词(打造/全面/系统性/赋能/行业领先)— P2
- 无 AI 腔(见 writing-style)— P2
- 半角标点带空格、面向同事 — P2
- 全文自洽(功能↔tool↔指标↔Non-Goals 不打架)— **P0**

## 输出格式

```
## PRD 评审: {页面标题}
### 1) 总判定
{✅通过 / ⚠️待修 / ⛔不通过} + 估分(结构完备50 + 合规质量50)+ 建议 status.
规则: 任一 P0 未过 → 最高 ⚠️待修、status=changes-requested; ≥85 且无 P0 → ✅通过/approved.
### 2) 逐条问题(点名到具体条目)
每条: [严重度] 点名 feature/指标/tool + 一句可执行修复.
例: "功能'活动订阅' [P0] 无对应 MCP tool 草案 → 补 subscribe_event(读/写) + 入参 category/club/keyword".
### 3) 亮点(若有, 简短)
```

中文, 克制, 不羞辱, 只讲事实和下一步。

## 边界

不改 PRD 正文(改是 @PM)。判定同步 Multica 评审 issue; 状态以 MR 为准(开着 = 评审中, 合并 master = 定稿)。工序: 我在 Multica issue 出判定(✅/⚠️/⛔ + P0/P1/P2 + 建议 status)与建议; 由 @PM 在同一分支 MR 里改, 批准集点头后由定稿人合并(我不动仓, 不 review-and-merge)。旧系统页面(若有)仅只读溯源, 不再写、不再盖 metadata。本 skill 只负责"评一份 + 给建议"。

> 文档真源是 GitLab `https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs`; 旧系统页面(若有)仅只读溯源, 不再写、不再盖 metadata。状态以 MR 为准: 开着 = 评审中, 合并 master = 定稿。我(@Critic)在 Multica 评审 issue 出判定与建议 status; 如需更新文件内 front matter `status`/`version`, 由 @PM 在同一分支 MR 改, 由定稿人合并。见 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `docs/collaboration-model.md`。

## 收尾(必做, 别漏)

判定盖完、评审意见回复到 Multica issue 之后, 顺手用 `multica issue status <issue-id> done` 把**当前这条**评审 issue 标成 `done`。评审这件事本身已经做完(不管判定是通过还是待修), 不要让 issue 停在 `in_progress`/`in_review` 冒充"还没评完"。如果判定是待修, 由 @PM 另开一条修订 issue, 不靠这条旧评审 issue 的状态来触发下一轮。
<!-- kit:sha256=99cd34bc449e08d2 -->
