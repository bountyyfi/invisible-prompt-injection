#!/bin/sh
set -e

# entrypoint.sh — Universal CI wrapper for injection_scan.py
#
# Works standalone, in Docker, or in any CI system.
# Reads config from environment variables so every CI platform
# can drive it the same way.
#
# Environment variables:
#   SCAN_PATH        File or directory to scan        (default: ".")
#   SCAN_RECURSIVE   Scan recursively (true/false)    (default: "true")
#   SCAN_FAIL_ON     Threshold: any|warning|critical  (default: "critical")
#   SCAN_EXCLUDE     Comma-separated exclude paths    (default: "")
#   SCAN_VERBOSE     Show details (true/false)        (default: "false")
#   SCAN_FORMAT      Output: text|json|github         (default: "text")
#
# Usage:
#   ./entrypoint.sh                          # scan current dir
#   SCAN_PATH=docs ./entrypoint.sh           # scan docs/
#   docker run --rm -v $(pwd):/workspace ghcr.io/bountyyfi/injection-scan

SCANNER="$(dirname "$0")/injection_scan.py"

# Fall back to finding it next to this script, or in PATH
if [ ! -f "$SCANNER" ]; then
  SCANNER="$(command -v injection_scan.py 2>/dev/null || echo "injection_scan.py")"
fi

SCAN_PATH="${SCAN_PATH:-.}"
SCAN_RECURSIVE="${SCAN_RECURSIVE:-true}"
SCAN_FAIL_ON="${SCAN_FAIL_ON:-critical}"
SCAN_EXCLUDE="${SCAN_EXCLUDE:-}"
SCAN_VERBOSE="${SCAN_VERBOSE:-false}"
SCAN_FORMAT="${SCAN_FORMAT:-text}"

ARGS="${SCAN_PATH}"

if [ "${SCAN_RECURSIVE}" = "true" ]; then
  ARGS="${ARGS} -r"
fi

if [ "${SCAN_VERBOSE}" = "true" ]; then
  ARGS="${ARGS} -v"
fi

ARGS="${ARGS} --fail-on ${SCAN_FAIL_ON}"

if [ -n "${SCAN_EXCLUDE}" ]; then
  ARGS="${ARGS} --exclude ${SCAN_EXCLUDE}"
fi

case "${SCAN_FORMAT}" in
  json)   ARGS="${ARGS} --json" ;;
  github) ARGS="${ARGS} --github" ;;
  *)      ;;  # text is default
esac

# If running inside GitHub Actions, auto-enable annotations
if [ -n "${GITHUB_ACTIONS}" ] && [ "${SCAN_FORMAT}" = "text" ]; then
  ARGS="${ARGS} --github"
fi

# If running inside GitLab CI, use codequality JSON by default
if [ -n "${GITLAB_CI}" ] && [ "${SCAN_FORMAT}" = "text" ]; then
  ARGS="${ARGS} --json"
fi

exec python3 "${SCANNER}" ${ARGS}
