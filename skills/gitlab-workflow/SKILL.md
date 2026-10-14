---
name: gitlab-workflow
description: 对接 MCD GitLab 的读代码/提交/MR 流程：走 GitLab MCP 工具，分支从 release 切、MR 目标由人类给定，agent 绝不 merge（Dev 用）。
---

# GitLab 操作（GitLab Workflow）

## 是什么 / 何时用

开发小队对接 MCD 内部 GitLab（`gitlab-ex.mcd.com.cn`）做「读代码 / 开发 / 提交」的操作约定。

**接入方式：GitLab MCP**（`streamable-http` → `https://mcp.mcd.ai/foundation/gitlab`，header `MCD_GITLAB_TOKEN`）。
读代码、提交、创建/查询 MR 一律通过 **GitLab MCP 提供的工具**完成；具体工具名以实际挂载的 GitLab MCP 工具清单为准
（典型能力：仓库/文件浏览、分支、提交、merge request 的创建与查询）。

**用**：读代码、切分支、提交、创建/查询 MR。

## 分支策略（先于一切 GitLab 操作，铁律）

### 切开发分支

- **一个需求一条开发分支**：同一需求的规格 / 架构 / 实现 / 补强全部在**同一条开发分支**上迭代，**不按阶段新建多条分支**（杜绝 spec / arch / impl 各一条）。
- **base 分支默认 = `release`**，开发分支一律从 `release` 切出。
- **找不到 `release` → 停下，@人类**。判据只有一个——远端真实存在 `release` 分支：

```bash
git fetch origin
git ls-remote --heads origin release
```

- 存在 → `git checkout -b <feature-branch> origin/release`
- 不存在（输出为空）→ **停下，@人类提供 base 分支名，等确认后再切**。绝不拿 `master` / `main` / `dev` / `develop` 等其他分支当 base 顶替，绝不自己推导猜测。

### 建 MR（目标分支）

- **MR 的目标分支（合并到哪）绝不自己推导**：开发分支完成后、建 MR 之前，必须 @人类，由人类明确给出目标分支名。这是 **MR 前置门禁（blocking）**。
- 人类给出目标分支 → 按给定值建 MR；人类没给 → **不建 MR**；已建 MR 若目标非人类所给 → **立即改指或关闭重开**。

### 开发分支命名（确定性，不靠猜）

- 功能：`feature-{task-id}-{slug}`
- 修复：`bugfix-{task-id}-{slug}`
- `{task-id}` 来自 TechLead 派活给的 issue/任务标识；`{slug}` = 标题小写、非 `[a-z0-9]` 字符塌缩为 `-`、去首尾 `-`。

## 操作方式（走 GitLab MCP 工具）

1. **读代码**：用 GitLab MCP 的仓库/文件浏览工具读取目标仓库与分支的代码。
2. **开发**：在本地 runtime 里改代码文件（本地 git 仍可用于 `git diff` 自查）。
3. **提交**：用 GitLab MCP 的提交工具把改动提交到开发分支（提交前必扫密钥、跑测试/lint）。
4. **建 MR**：用 GitLab MCP 的 merge request 工具创建 MR，目标分支由人类给出（见上）。
5. **查 MR 状态**：用 GitLab MCP 的 MR 查询工具核对状态/审批/合并 SHA。

> 若 GitLab MCP 工具缺失某一步能力，回退到本地 `git` + `glab`（凭据走 GitLab MCP 的认证，不硬编码 token），仍遵守下方全部铁律。

## 铁律

1. **Agent 绝不 merge MR**——merge 是人的职责。人合并后，agent 用 MR 状态查询验证合并 SHA 再推进。
2. **不硬编码 project id / 路径**——一律从仓库上下文或 remote 动态解析，避免推到错误项目。
3. **合并后清理源分支**（`remove_source_branch` 或等价动作），并显式确认源分支已删。
4. **提交前扫密钥**——改动里出现 `password/secret/api_key/token` 立即停。

## 反自我合理化

| 借口 | 现实 |
|---|---|
| 「project id 我记得」 | 记错就推错仓，永远动态解析 |
| 「agent 可以帮忙 merge」 | merge 是人的责任，agent 只验证 |
| 「token 直接写代码里」 | token 进代码 = 泄密事故，凭据只走 MCP header |

## 完成判据

- [ ] 开发分支从 `release` 切出（找不到 release 已 @人类）
- [ ] MR 目标分支由人类给定，未自行推导
- [ ] 提交通过 GitLab MCP 完成，未硬编码凭证
- [ ] agent 未执行 merge，仅验证状态
- [ ] 提交 diff 无密钥
