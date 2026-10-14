#!/usr/bin/env bash
#
# 开发小队 / Dev Squad — 一键安装 (one-click installer)
#
# 把本仓库里的 6 个 agent + 1 个 squad + 29 个 skill 安装到目标环境。
#
#   ./install.sh                     # 自动探测: 有 multica 就装 multica，否则装 opencode 技能
#   ./install.sh --target multica    # 装进 Multica 工作区 (需要已登录的 multica CLI)
#   ./install.sh --target opencode   # 把 skills/ 复制到 ./.opencode/skills
#   ./install.sh --target claude     # 把 skills/ 复制到 ./.claude/skills
#   ./install.sh --target ./some/dir # 把 skills/ 复制到 ./some/dir/skills
#
# 选项:
#   --runtime-id <id>   创建 agent 用的 runtime (默认自动取第一个 online runtime)
#   --repo-url <url>    skill 从远端导入时用的仓库地址 (配 --from-url)
#   --from-url          用 `multica skill import --url` 从远端导入 skill, 而不是本地创建
#   --force             已存在的 skill / agent / squad 也覆盖或重建
#   --dry-run           只打印将要执行的命令, 不落地
#   -h, --help          显示帮助
#
# 设计原则: 幂等 (默认跳过已存在项) / 无秘密入库 / 失败即停并报错。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
DEFAULT_REPO_URL="https://github.com/xiangxiushen/ai-coding-team"

TARGET="auto"
RUNTIME_ID="${RUNTIME_ID:-}"
REPO_URL="${REPO_URL:-$DEFAULT_REPO_URL}"
FROM_URL=0
FORCE=0
DRY_RUN=0

log()  { printf '\033[1;34m[dev-squad]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

usage() { sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '  $'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target)    TARGET="$2"; shift 2 ;;
    --runtime-id) RUNTIME_ID="$2"; shift 2 ;;
    --repo-url)  REPO_URL="$2"; shift 2 ;;
    --from-url)  FROM_URL=1; shift ;;
    --force)     FORCE=1; shift ;;
    --dry-run)   DRY_RUN=1; shift ;;
    -h|--help)   usage ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

[ -f "$REPO_ROOT/manifest.json" ] || die "manifest.json not found next to install.sh"
command -v jq >/dev/null 2>&1 || die "jq is required"

# ---------------------------------------------------------------------------
# generic: copy skills into a skills directory (opencode / claude / any dir)
# ---------------------------------------------------------------------------
copy_skills() {
  local skills_dir="$1"
  log "copying skills -> $skills_dir"
  run mkdir -p "$skills_dir"
  run cp -R "$REPO_ROOT"/skills/. "$skills_dir"/
  # drop the index helper we keep only for the installer
  [ "$DRY_RUN" = "1" ] || rm -f "$skills_dir/index.json"
  log "installed $(ls "$REPO_ROOT/skills" | grep -v index.json | wc -l | tr -d ' ') skills"
  log "note: agents/squad are Multica-native; for opencode/claude, skills are the portable unit."
}

target_dir_for() {
  case "$1" in
    opencode) echo "./.opencode/skills" ;;
    claude)   echo "./.claude/skills" ;;
    *)        echo "$1/skills" ;;
  esac
}

# ---------------------------------------------------------------------------
# multica: create skills, agents, then the squad
# ---------------------------------------------------------------------------
multica_install() {
  command -v multica >/dev/null 2>&1 || die "multica CLI not found; install it or use --target opencode"

  if [ -z "$RUNTIME_ID" ]; then
    RUNTIME_ID="$(multica runtime list --output json 2>/dev/null \
      | jq -r 'if type=="array" then . else (.runtimes // .items // []) end | map(select(.status=="online"))[0].id // empty')"
  fi
  [ -n "$RUNTIME_ID" ] || die "no online runtime found; pass --runtime-id <id>"
  log "runtime: $RUNTIME_ID"

  local skill_json existing_skills
  skill_json="$(multica skill list --output json)"

  # ---- skills ----
  log "installing skills"
  local d name desc sid
  for d in "$REPO_ROOT"/skills/*/; do
    [ -f "$d/SKILL.md" ] || continue
    name="$(basename "$d")"
    [ "$name" = "index.json" ] && continue
    desc="$(jq -r --arg n "$name" '.[$n].description // ""' "$REPO_ROOT/skills/index.json")"
    existing_skills="$(multica skill list --output json | jq -r '.[].name')"
    if printf '%s\n' "$existing_skills" | grep -qx "$name"; then
      if [ "$FORCE" = "1" ]; then
        warn "skill exists, --force set but multica skills are immutable by name; skipping $name (use the workspace UI to overwrite)"
      else
        log "  skip (exists): $name"
      fi
      continue
    fi
    if [ "$FROM_URL" = "1" ]; then
      log "  import: $name"
      run multica skill import --url "$REPO_URL/tree/main/skills/$name" --on-conflict skip
    else
      log "  create: $name"
      run multica skill create --name "$name" --description "$desc" --content-file "$d/SKILL.md"
    fi
  done

  # refresh the name->id map
  skill_json="$(multica skill list --output json)"

  # ---- agents ----
  log "installing agents"
  local f aname adesc ainstr amodel amct aid sid_csv skill_names
  for f in "$REPO_ROOT"/agents/*.json; do
    [ -f "$f" ] || continue
    aname="$(jq -r '.name' "$f")"
    adesc="$(jq -r '.description // ""' "$f")"
    ainstr="$(jq -r '.instructions' "$f")"
    amodel="$(jq -r '.model // ""' "$f")"
    amct="$(jq -r '.max_concurrent_tasks // 6' "$f")"

    if multica agent list --output json | jq -r '.[].name' | grep -qx "$aname"; then
      log "  skip (exists): $aname"
      continue
    fi
    log "  create: $aname"
    local cargs=(multica agent create --name "$aname" --description "$adesc"
      --instructions "$ainstr" --runtime-id "$RUNTIME_ID"
      --max-concurrent-tasks "$amct" --permission-mode public_to
      --public-to-workspace --output json)
    [ -n "$amodel" ] && cargs+=(--model "$amodel")
    if [ "$DRY_RUN" = "1" ]; then
      run "${cargs[@]}"
      continue
    fi
    aid="$("${cargs[@]}" | jq -r '.id')"
    [ -n "$aid" ] && [ "$aid" != "null" ] || die "failed to create agent $aname"

    # bind skills
    skill_names="$(jq -r '.skills[]' "$f")"
    sid_csv=""
    local s
    while IFS= read -r s; do
      [ -z "$s" ] && continue
      sid="$(printf '%s' "$skill_json" | jq -r --arg n "$s" '.[] | select(.name==$n) | .id' | head -1)"
      if [ -z "$sid" ]; then warn "  skill not found for binding: $s"; continue; fi
      sid_csv="${sid_csv:+$sid_csv,}$sid"
    done <<< "$skill_names"
    if [ -n "$sid_csv" ]; then
      log "    bind $(printf '%s' "$skill_names" | wc -l | tr -d ' ') skills"
      run multica agent skills add "$aid" --skill-ids "$sid_csv"
    fi
  done

  # ---- squad ----
  log "installing squad"
  local sname sleader sdesc squad_id
  sname="$(jq -r '.squad.name // "开发小队"' "$REPO_ROOT/manifest.json")"
  sleader="$(jq -r '.squad.leader // "DevSquad-TechLead"' "$REPO_ROOT/manifest.json")"
  sdesc="$(jq -r '.description // ""' "$REPO_ROOT/squad/dev-squad.json")"
  if multica squad list --output json | jq -r '.[].name' | grep -qx "$sname"; then
    log "  skip (exists): $sname"
  else
    log "  create: $sname (leader=$sleader)"
    if [ "$DRY_RUN" = "1" ]; then
      run multica squad create --name "$sname" --leader "$sleader" --description "$sdesc"
    else
      squad_id="$(multica squad create --name "$sname" --leader "$sleader" --description "$sdesc" | jq -r '.id')"
      [ -n "$squad_id" ] && [ "$squad_id" != "null" ] || die "failed to create squad"
      local m mname mid
      local agent_json; agent_json="$(multica agent list --output json)"
      for m in $(jq -r '.members[] | select(.role!="leader") | .name' "$REPO_ROOT/squad/dev-squad.json"); do
        mid="$(printf '%s' "$agent_json" | jq -r --arg n "$m" '.[] | select(.name==$n) | .id' | head -1)"
        [ -z "$mid" ] && { warn "  member agent not found: $m"; continue; }
        log "  add member: $m"
        run multica squad member add "$squad_id" --member-id "$mid" --role member --type agent
      done
    fi
  fi

  log "done. open your Multica workspace — 开发小队 is ready."
  log "tip: agents bind to the runtime '$RUNTIME_ID'; re-point them in the UI if you want a different runtime."
}

# ---------------------------------------------------------------------------
main() {
  case "$TARGET" in
    auto)
      if command -v multica >/dev/null 2>&1; then TARGET="multica"; else TARGET="opencode"; fi
      log "auto-detected target: $TARGET"
      ;;
  esac
  case "$TARGET" in
    multica) multica_install ;;
    opencode|claude) copy_skills "$(target_dir_for "$TARGET")" ;;
    *) copy_skills "$(target_dir_for "$TARGET")" ;;
  esac
}

main "$@"
