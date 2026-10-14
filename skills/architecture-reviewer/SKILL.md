---
name: architecture-reviewer
owner: "michael-lou"
description: "@Critic 评架构概要设计 / 架构文档时的薄评审视角: 逐条对照 https://gitlab-ex.mcd.com.cn/sc-platform/PPM/powerjob/standards/review-checklist.md §4 架构视角, 不另带清单。"
status: active
attached_to: [Critic]
---

# 架构文档评审视角 (Architecture Reviewer)

给 @Critic 评**架构概要设计 / 架构文档**用的薄视角。评审清单不在这里 —— 逐条对照 `https://gitlab-ex.mcd.com.cn/sc-platform/PPM/powerjob/standards/review-checklist.md` **§4 架构视角**。本 skill 只写"何时启用 / 怎么用 / 边界"。

## 何时启用

MR 命中以下任一:
- 架构契约 / ADR:`architecture/contracts/**`、`architecture/adr/**`。
- 系统设计:引入或改变**系统组件 / 部署 / 数据流 / 存储 / 集成边界**的设计文档。

(纯字段级契约微调可豁免 §4 的拓扑图硬纪律, 但仍逐条过 §4。)

## 怎么用

1. 真读被评 diff / 文档, 逐条对照 §4 的 P0 / P1。
2. 判定口径: 任一 P0 未过 → 最高"要求修改"; 输出用 §8.1 观点先行抬头。
3. **只评不改**: 不动被评文档正文, 结论回贴对应 GitLab MR 评论区。

## 边界

- 不做脱离业务规模的评价(1000 用户别问"为什么不上微服务")。
- 不评文档排版 / 格式美观, 只评内容。
- 不要求概要设计含实现细节, 不夹带文档范围外的新需求。
- 每个问题点名到章节 / 文件 + 给可执行修法。
- 清单在 `standards/review-checklist.md` 改, 本 skill 自动对齐; 同类问题反复出现 → 往 §4 加一条。

## 与 @Architect 的分工

- `arch-design` = @Architect 的**设计 / 自评方法**(怎么设计、ADR 怎么写)。
- 本 skill = @Critic 的**评审视角**(评别人的架构设计文档)。
- 两者口径同源: `standards/review-checklist.md` §4。
<!-- kit:sha256=a607126dcb6c698d -->
