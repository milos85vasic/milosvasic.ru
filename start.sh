#!/bin/bash
# Serve the site locally.
#   ./start.sh                      host Jekyll (unchanged default)
#   ./start.sh --runner=NAME        serve Jekyll INSIDE a container, forced runner NAME
#   ./start.sh --container          same, runner chosen by the module's default order
#   ./start.sh --runner=auto        host Jekyll; runner choice validated, no containers used
# Optional: --dry-run prints the command instead of running it.
# Contract: Containers module docs/RUNNER_FLAG.md (unknown / not-installed runner
# -> rc 2, never a silent fallback). Module lookup: $CONTAINERS_DIR, else
# ../submodules/containers (umbrella layout).

mv_usage() {
  cat <<'USAGE'
Usage: ./start.sh [--runner=NAME | --runner NAME | --container] [--dry-run]
  (no args)         serve with host Jekyll: bundle install && bundle exec jekyll serve
  --runner=NAME     serve Jekyll inside a container, forced runner NAME (auto = host Jekyll)
  --container       serve inside a container, runner chosen by the module's default order
  --dry-run         print the command instead of running it
  -h, --help        print this help and exit 0
Env: CONTAINERS_RUNNER, CONTAINERS_DIR. Any other argument is an error (rc 2).
USAGE
}
# Help wins over everything and runs before any side effect.
for a in "$@"; do case "$a" in -h|--help) mv_usage; exit 0 ;; esac; done

mv_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mv_want=0; mv_container=0; mv_dry=0; mv_rest=(); mv_unknown=""
while [ "$#" -gt 0 ]; do
  a="$1"; shift
  case "$a" in
    --runner) mv_want=1; mv_rest+=("$a")
      # value form `--runner NAME`: pass the value through; a missing/dash value is the module's rc 2
      if [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ]; then mv_rest+=("$1"); shift; fi ;;
    --runner=*) mv_want=1; mv_rest+=("$a") ;;
    --container) mv_container=1 ;;
    --dry-run) mv_dry=1 ;;
    *) mv_unknown="$a" ;;
  esac
done
if [ -n "$mv_unknown" ]; then
  echo "start.sh: unknown argument '$mv_unknown'" >&2; mv_usage >&2; exit 2
fi
[ -n "${CONTAINERS_RUNNER:-}" ] && mv_want=1

if [ "$mv_want" = 0 ] && [ "$mv_container" = 0 ]; then
  # Default path: byte-compatible with the previous start.sh.
  if [ "$mv_dry" = 1 ]; then echo "bundle install && bundle exec jekyll serve"; exit 0; fi
  bundle install && bundle exec jekyll serve
  exit $?
fi

mv_lib=""
for d in "${CONTAINERS_DIR:-}" "$mv_here/../submodules/containers"; do
  if [ -n "$d" ] && [ -f "$d/scripts/lib/runner.sh" ]; then
    CONTAINERS_DIR="$(cd "$d" && pwd)"; export CONTAINERS_DIR; mv_lib="$CONTAINERS_DIR/scripts/lib/runner.sh"; break
  fi
done
if [ -z "$mv_lib" ]; then
  echo "runner: --runner/--container/CONTAINERS_RUNNER need the Containers module (scripts/lib/runner.sh); set CONTAINERS_DIR to a checkout of vasic-digital/containers" >&2
  exit 2
fi
# shellcheck disable=SC1090
source "$mv_lib"
runner_parse_args "${mv_rest[@]+"${mv_rest[@]}"}" || exit 2
set -- "${RUNNER_REST[@]+"${RUNNER_REST[@]}"}"
runner_select || exit 2

# Container mode only when a runner was forced by flag, or --container was given.
if [ "$mv_container" = 0 ] && { [ "$RUNNER_FLAG_SET" = 0 ] || [ "$RUNNER_FLAG_VALUE" = auto ]; }; then
  echo "runner: ${CONTAINERS_RUNNER_CHOSEN} (no containers used; host Jekyll serve)"
  if [ "$mv_dry" = 1 ]; then echo "bundle install && bundle exec jekyll serve"; exit 0; fi
  bundle install && bundle exec jekyll serve
  exit $?
fi

read -r -a mv_compose <<<"$(runner_compose_cmd)" || exit 2
[ "${#mv_compose[@]}" -gt 0 ] || { echo "runner: no compose command for ${CONTAINERS_RUNNER_CHOSEN}" >&2; exit 2; }
export MV_SITE_DIR="$mv_here"
mv_file="$mv_here/_container/compose.serve.yml"
echo "serving Jekyll in a container via: ${mv_compose[*]} (runner ${CONTAINERS_RUNNER_CHOSEN})"
if [ "$mv_dry" = 1 ]; then echo "${mv_compose[*]} -p milosvasic-ru-serve -f $mv_file up"; exit 0; fi
trap '"${mv_compose[@]}" -p milosvasic-ru-serve -f "$mv_file" down >/dev/null 2>&1' EXIT
"${mv_compose[@]}" -p milosvasic-ru-serve -f "$mv_file" up
