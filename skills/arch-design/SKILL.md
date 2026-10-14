---
name: arch-design
owner: "michael-lou"
description: "@Architect 怎么给 SC-SDLC 做技术设计与架构设计: MCP-first 契约优先、ADR 落定、NFR 对照、分期切片。产出写进 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs `architecture/adr/` 与 `architecture/contracts/`, 走 MR。自评口径引用 `standards/review-checklist.md` §4 架构视角。"
status: active
attached_to: [Architect]
---

# arch-design

守住架构底线, 让每个域的实现对得上 10 条设计原则和 NFR。契约优先, 不放过"没 tool 定义"的功能。

> 本 skill 是 @Architect 的**设计 / 自评方法**, 不另带一套评审清单。评审口径的单一真源是 `https://gitlab-ex.mcd.com.cn/sc-platform/PPM/powerjob/standards/review-checklist.md` **§4 架构视角** —— 提 MR 前逐条对照自评, @Critic 评审时用同一份。

## 设计要点(设计时守的底线)

**A1 MCP-first(P1 原则, 硬)**
- 每个新功能都有对应 MCP tool 定义(名字 + 入参 + 读/写)。无 tool 定义 = 硬线拦截(见 §4 MCP 覆盖), CI 也会拦。
- 领域服务层是唯一真源, Web 前端与 MCP server 都是薄壳, 不在前端写业务逻辑。

**A2 契约冻结(G2 前置)**
- OpenAPI + MCP schema 齐、可 lint、进 CI。
- 契约与 PRD 的 tool 草案一致, 不打架。

**A3 数据与边界**
- Content once, render everywhere: 内容是结构化对象存 headless 中枢, Web/企微/邮件/屏幕都是渲染面, 不各存一份。
- 权限矩阵(concept §9)落到 tool 级鉴权;agent 与人走同一套 tools(P9 dogfooding), 独立身份 + 全审计 + 一键暂停。

**A4 隐私与合规(P4, 硬)**
- 字段级可见性、被动方否决权在数据模型里就能表达。
- 人脸/声纹属 PIPL 生物特征, v1 严格人工圈选, 不上自动识别。

**A5 NFR 对照(concept §19)**
- 性能/可用性/可扩展/可观测/可维护有明确目标, 不是"尽量快"。
- feature flag 内置, 能灰度能回滚;kill switch(尤其屏幕 render_to_screen)。

**A6 分期可切**
- 能切出"行走骨架"(G3): 一条最薄端到端(活动→照片采集→Feed/屏幕)同走 MCP + Web。
- 不为 v1 引入 Phase 2/3 才需要的复杂度(如 Event Graph、语义检索)。

## 自评(提 MR 前)

对照 `standards/review-checklist.md` **§4 架构视角**逐条过, P0/P1 全过再提。重点硬纪律:
- 横切约定引用上位基线, 不重写。
- 字段级 schema / error_code / 副作用写清; REST 与 MCP 口径一致。
- **拓扑图必交**: 引入或改变系统组件 / 部署 / 数据流 / 存储 / 集成边界的设计, 必含一张 mermaid 拓扑图(组件 / 部署 / 数据流至少一视角)。
- ADR 编号唯一、决策 / 理由 / 备选清楚。

## ADR 怎么写

一个决策一页, 写进 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs 的 `architecture/adr/` 目录。结构: 背景 / 决策 / 备选与取舍 / 影响 / 状态。编号 ADR-N。契约类决策同时在 `architecture/contracts/` 留人读摘要 + 指向代码仓(后端 `https://gitlab-ex.mcd.com.cn/sc-platform/PPM/powerjob`)的指针。文件头部 YAML front matter 标 `status` / `version`; 经 Multica 评审 issue 批准后由定稿人把 MR 合并进 master(合并即定稿)。权威版本以 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs master 为准; 旧系统页面(若有)仅只读溯源, 不再写、不再盖 metadata。

## 输出

- 设计产出(ADR / 契约摘要)写到 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs 的 `architecture/adr/` 与 `architecture/contracts/` 目录, 走 MR; 判定同步到 Multica 评审 issue。
- 自评结论按 `standards/review-checklist.md` §4 逐条点名, 判定 ✅通过 / ⚠️待修 / ⛔不通过 + 可执行修复。
- 协作找 @Architect;旧入口(若有)只作只读回看, 不写仓。
- 守 `writing-style`;状态以 MR / Git 为准, 不在旧系统盖 metadata。
<!-- kit:sha256=e2689ef84fcbe83e -->
