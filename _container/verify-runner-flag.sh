#!/usr/bin/env bash
# Real-host proof of start.sh's --runner/--container contract (Containers module docs/RUNNER_FLAG.md).
# Uses start.sh --dry-run so nothing is started; the live serve is a separate manual proof (see README).
# Exit: 0 pass, 1 finding, 2 could not determine. --prove-failure: mutations of a start.sh copy must each fail.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
START="${START_SH:-$HERE/start.sh}"
fails=0
chk() { if [ "$2" = "$3" ]; then echo "  PASS $1"; else echo "  FAIL $1 (got '$2' want '$3')"; fails=$((fails+1)); fi; }
checks() {
  local present="" absent="" r out rc
  for r in podman docker nerdctl; do
    if command -v "$r" >/dev/null 2>&1; then [ -n "$present" ] || present="$r"; else [ -n "$absent" ] || absent="$r"; fi
  done
  [ -n "$present" ] && [ -n "$absent" ] || { echo "COULD NOT DETERMINE: need one installed and one absent runner"; return 2; }
  local d="${CONTAINERS_DIR:-$HERE/../submodules/containers}"
  [ -f "$d/scripts/lib/runner.sh" ] || { echo "COULD NOT DETERMINE: no $d/scripts/lib/runner.sh"; return 2; }
  export CONTAINERS_DIR="$d"; unset CONTAINERS_RUNNER
  out="$(bash "$START" --dry-run 2>&1)"; chk "default: host command only, no runner output" "$out" "bundle install && bundle exec jekyll serve"
  # the executed host command: a PATH shim records what start.sh really invokes (glue check only; the live
  # container serve is the real-runtime proof)
  local sh; sh="$(mktemp -d)"; printf '#!/bin/sh\necho "bundle $*"\n' > "$sh/bundle"; chmod +x "$sh/bundle"
  out="$(PATH="$sh:$PATH" bash "$START" 2>&1)"; chk "default executes bundle install then jekyll serve" "$(echo "$out" | paste -sd'|')" "bundle install|bundle exec jekyll serve"
  out="$(PATH="$sh:$PATH" bash "$START" --runner=auto 2>&1 | grep '^bundle' | paste -sd'|')"; chk "--runner=auto executes the host serve" "$out" "bundle install|bundle exec jekyll serve"
  rm -rf "$sh"
  out="$(bash "$START" --runner="$present" --dry-run 2>&1)"; rc=$?
  chk "--runner=$present exits 0" "$rc" 0
  case "$out" in *"-p milosvasic-ru-serve -f"*"compose.serve.yml up"*) chk "--runner=$present serves in a container" 1 1 ;; *) chk "--runner=$present serves in a container" "$out" "compose up line" ;; esac
  out="$(bash "$START" --runner="$absent" --dry-run 2>&1)"; rc=$?; chk "--runner=$absent (not installed) refused" "$rc" 2
  case "$out" in *"compose.serve.yml"*|*"jekyll serve"*) chk "no fallback command printed for $absent" "$out" "nothing" ;; esac
  bash "$START" --runner=bogus --dry-run >/dev/null 2>&1; chk "unknown runner refused" $? 2
  CONTAINERS_RUNNER=bogus bash "$START" --dry-run >/dev/null 2>&1; chk "env CONTAINERS_RUNNER=bogus refused" $? 2
  bash "$START" --runner --dry-run >/dev/null 2>&1; chk "valueless --runner refused" $? 2
  out="$(bash "$START" --runner=auto --dry-run 2>&1)"; rc=$?; chk "--runner=auto exits 0" "$rc" 0
  case "$out" in *"no containers used"*"bundle install && bundle exec jekyll serve"*) chk "--runner=auto stays on the host" 1 1 ;; *) chk "--runner=auto stays on the host" "$out" "host serve" ;; esac
  out="$(bash "$START" --container --dry-run 2>&1)"; rc=$?; chk "--container exits 0" "$rc" 0
  case "$out" in *"compose.serve.yml up"*) chk "--container uses a container" 1 1 ;; *) chk "--container uses a container" "$out" "compose up" ;; esac
  # module absent: run a COPY in an isolated dir so the ../submodules/containers fallback cannot exist
  local iso; iso="$(mktemp -d)"; mkdir -p "$iso/site"; cp "$START" "$iso/site/start.sh"
  CONTAINERS_DIR=/nonexistent bash "$iso/site/start.sh" --runner="$present" --dry-run >/dev/null 2>&1; chk "flag with module absent refused (not ignored)" $? 2
  rm -rf "$iso"
  # --help / unknown arguments: usage or rc 2 BEFORE any side effect (a PATH shim must never be invoked)
  local sh2 hit; sh2="$(mktemp -d)"; printf '#!/bin/sh\necho invoked >> "%s/hit"\n' "$sh2" > "$sh2/bundle"; chmod +x "$sh2/bundle"
  out="$(PATH="$sh2:$PATH" bash "$START" --help 2>&1)"; rc=$?; chk "--help exits 0" "$rc" 0
  case "$out" in *Usage*) chk "--help prints usage" 1 1 ;; *) chk "--help prints usage" "$out" "Usage text" ;; esac
  PATH="$sh2:$PATH" bash "$START" -h >/dev/null 2>&1; chk "-h exits 0" $? 0
  PATH="$sh2:$PATH" bash "$START" --bogus-flag >/dev/null 2>&1; chk "unknown flag refused rc 2" $? 2
  PATH="$sh2:$PATH" bash "$START" stray-word >/dev/null 2>&1; chk "stray positional refused rc 2" $? 2
  PATH="$sh2:$PATH" bash "$START" --runner="$present" --bogus-flag --dry-run >/dev/null 2>&1; chk "unknown flag with --runner refused rc 2" $? 2
  hit=none; [ -e "$sh2/hit" ] && hit=invoked; chk "help/unknown never invoked the host bundle" "$hit" none
  rm -rf "$sh2"
  [ "$fails" = 0 ]
}
if [ "${1:-}" = "--prove-failure" ]; then
  W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT; caught=0; total=0
  mutate() { total=$((total+1)); cp "$HERE/start.sh" "$W/start.sh"; sed -i "$2" "$W/start.sh"
    if cmp -s "$HERE/start.sh" "$W/start.sh"; then echo "  MUTATION $1 changed nothing"; return; fi
    if START_SH="$W/start.sh" bash "$0" >/dev/null 2>&1; then echo "  SURVIVED $1"; else caught=$((caught+1)); echo "  KILLED   $1"; fi; }
  mutate M1-skip-select 's/^runner_select || exit 2$/true/' 
  mutate M2-module-missing-ignored '/^  exit 2$/{x;s/^/x/;/^x\{1\}$/{x;s/exit 2/exit 0/;b};x}'
  mutate M3-default-path-changed 's/^  bundle install \&\& bundle exec jekyll serve$/  bundle install \&\& bundle exec jekyll build/'
  mutate M4-flag-forces-host-always 's/^if \[ "\$mv_container" = 0 \] \&\& .*$/if true; then/'
  mutate M5-parse-error-ignored 's/runner_parse_args "\${mv_rest\[@\]+"\${mv_rest\[@\]}"}" || exit 2/runner_parse_args "${mv_rest[@]+"${mv_rest[@]}"}"/'
  mutate M6-unknown-falls-through 's/^    \*) mv_unknown="\$a" ;;$/    *) mv_rest+=("\$a") ;;/'
  mutate M7-help-ignored 's/-h|--help) mv_usage; exit 0 ;;/-h|--help) : ;;/'
  echo "prove-failure: $caught/$total mutations killed"; [ "$caught" = "$total" ] && exit 0 || exit 1
fi
checks; rc=$?; [ "$rc" = 0 ] && echo "runner-flag: OK" || echo "runner-flag: rc=$rc"; exit $rc
