---
name: git-workflow-and-versioning
description: 原子提交、commit 规范、变更尺寸、主干开发（Dev 提交用）。
---

# Git 工作流与版本化（Git Workflow & Versioning）

## 是什么 / 何时用

Git 是安全网。提交是存档点，分支是沙盒，历史是文档。AI 高速产码时，规范的版本控制是让改动「可管理、可评审、可回滚」的机制。

**用**：任何代码改动——提交、分支、解决冲突、拆 messy 工作区、开 PR、发版。

## 核心原则

### 主干开发（推荐）

`main` 永远可部署，工作在 1-3 天内的短命 feature 分支完成。长命分支是隐性成本（漂移、冲突、延迟集成）。用 feature flag 代替长命分支承载未完成功能。

### 1. 早提交、常提交

每个成功增量一个提交，不要攒大堆未提交改动。

```
实现切片 → 测试 → 验证 → 提交 → 下一片   （不是：全写完 → 赌一把 → 巨型提交）
```

### 2. 原子提交

一个提交做一件逻辑上的事。

### 3. 描述性 message（讲 why 不讲 what）

```
<type>: <短描述>

<可选正文，解释为什么，而非改了什么>
```
类型：`feat` / `fix` / `refactor` / `test` / `docs` / `chore`

### 4. 关注点分离

格式化改动不混进行为改动；重构不混进功能。各是各的提交（理想是各的 PR）。

### 5. 控制尺寸

`~100 行` 好审好回滚 / `~300 行` 单一逻辑变更可接受 / `~1000 行` 必须拆。

## Save Point 模式

每步改动：测试过 → 提交继续；测试挂 → 回退到上个提交 → 排查。这样最多丢一个增量的工作，agent 跑偏了 `git reset --hard HEAD` 立即回到上个好状态。

## 变更摘要

改完给结构化摘要，便于评审 + 暴露越界改动：

```
CHANGES MADE: ...
THINGS I DIDN'T TOUCH (intentionally): ...   ← 体现范围纪律
POTENTIAL CONCERNS: ...
```

## 提交前卫生

提交前：`git diff --staged` 自查 → 扫密钥（password/secret/api_key/token）→ 跑测试 → 跑 lint → 跑类型检查。

## 生成物处理

- 项目期望的才提交（`package-lock.json`、migration）。
- 不提交：build 产物（`dist/`、`.next/`）、环境文件（`.env`）、IDE 配置。
- 必须有 `.gitignore` 覆盖 `node_modules/`、`dist/`、`.env*`、`*.pem`。

## 语义化版本（有下游消费者时）

- `MAJOR` 破坏性变更（消费者要改代码才能升级）
- `MINOR` 新增功能，向后兼容
- `PATCH` bug 修复，向后兼容
- 发版打 tag，版本从 tag 派生，别手改散落各处的版本号。
- changelog 写给人看（按 Added/Changed/Fixed 分组，写用户影响），不是 `git log` 的搬运。

## 反自我合理化

| 借口 | 现实 |
|---|---|
| 「功能做完再提交」 | 巨型提交没法审、没法 debug、没法回滚 |
| 「message 无所谓」 | message 是文档，未来的你（和 agent）要靠它懂为什么 |
| 「以后再 squash」 | squash 摧毁开发叙事，一开始就干净提交 |
| 「改动以后拆」 | 大改动更难审、更险、更难回滚，提交前拆 |
| 「不用 .gitignore」 | 直到 `.env` 带生产密钥进了历史 |

## 完成判据

- [ ] 提交做一件逻辑的事
- [ ] message 讲 why、符合 type 约定
- [ ] 提交前测试过
- [ ] diff 无密钥
- [ ] 格式化改动与行为改动分离
- [ ] `.gitignore` 覆盖标准排除项
