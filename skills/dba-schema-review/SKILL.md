---
name: dba-schema-review
description: "DBA / 数据库设计评审视角(通用): 对建表 / 改数据模型的 MR 审 schema 归属唯一 owner、建表前查重、约束保不变量、索引对齐查询、迁移可回滚与在线性; 引擎相关条款按 project.db.* 配置启用。挂 Architect(产出)+ Critic(评审)。"
status: active
---

# DBA / 数据库设计评审 skill

给 @Architect（产出物理 schema）和 @Critic（评审）加一层专业 DBA 视角。用于任何**引入或修改数据库表 / 数据模型**的 MR。

## 何时启用
MR 含 `.sql` / 迁移文件、`architecture/data/**`，或 PRD / 架构文档里有「数据模型 / 建表 / schema」章节时。

## 本项目的数据库约定（来自配置）

- 数据库引擎: `<未配置:project.db.engine>`
- 主键 / ID 策略: `<未配置:project.db.id_strategy>`
- schema / 库布局: `<未配置:project.db.schema_layout>`
- 物理设计标准文档: `<未配置:project.db.standard_doc>`（评审时对照；与本 skill 冲突以该文档为准）

> 上面四项由 `project.db.*` 配置给出。配置缺省时按下面的「通用审查项」审，引擎相关条款标注为「若适用」。

## 评审清单

评审清单的单一真源是 [standards/review-checklist.md](https://gitlab-ex.mcd.com.cn/sc-platform/PPM/docs/-/blob/master/kit/standards/review-checklist.md)（docs 仓 `kit/` 发布副本）的 **DBA 视角**一节；此处只补充 DBA 专项，不另写一套。评审时逐条核对 P0 / P1 项。

### 通用审查项（任何引擎）

1. **schema 归属唯一 owner**: 一个业务实体的物理表只能有一个 owner（仓 / 服务 / 域）。其他方需要该数据 → 调 owner 的 API，**禁止**在自己的库里再建一套同语义表。评审含建表的 MR 时，先确认该实体是否已在别处有权威表或被 ADR 冻结所有权。
2. **建表前查重(防脑裂)**: 任何 `CREATE TABLE` 前，先检索主分支迁移目录是否已有同名 / 近似名表（含单复数变体）。已存在 → 必须 `ALTER` 扩展，**禁止**新建平行表。
3. **不变量由约束保证**: 非空、唯一、外键 / 引用、CHECK 要落在 schema 上，关键约束旁标注不变量编号；不靠应用自觉。
4. **索引对齐查询模式**: 列表 / 时间线 / 游标分页要有对应索引；高基数过滤列建索引；避免无用索引与重复索引。
5. **命名与注释**: 表 / 列命名一致（风格以标准文档为准），关键表列写注释说明用途与不变量。
6. **迁移安全**: 一个域一套迁移目录，归属该域 owner；迁移可回滚；破坏性变更显式标注；大表变更评估锁与在线性（分批 / 在线 DDL）。
7. **软删除与数据生命周期**: 软删除 / 归档 / 保留期口径统一；大对象用引用计数 + 回收，不直接删。
8. **权限 / 可见性过滤列**: 所有按权限过滤的查询应走已物化并建索引的列，避免每次计算。
9. **触及 schema 迁移属 G-SEC**: 数据库迁移文件的合并不由 agent 自行放行（见 skill `team-canon` 的人的闸门），评审结论写进 `design-review` / `code-review` 判定。

### 引擎相关条款（若适用）

- 当 `<未配置:project.db.engine>` 为 PostgreSQL 时: 枚举优先 `text + CHECK` 而非原生 enum（生产库 ALTER enum 会阻塞）；时间列用 `timestamptz`；ID 遵循 `<未配置:project.db.id_strategy>`；多域布局遵循 `<未配置:project.db.schema_layout>`（例如每域独立 schema，跨域只按 ID 松引用、不做跨 schema 外键）。
- 其他引擎: 按其等价最佳实践与标准文档审，评审意见里写明依据。

## 评审产出
逐条给「过 / 不过 + 原因 + 建议」。不过的点必须具体到表 / 列 / 约束。**只评不改**(Critic); Architect 用本清单自查后再提。

## 边界
概念数据模型（有哪些实体 / 关系）属 PM / PRD；物理 DDL / 索引 / 库布局属 @Architect。DBA 视角只管物理设计与库约定。
<!-- kit:sha256=4f5b533ba079fd36 -->
