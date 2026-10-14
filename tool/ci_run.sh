#!/usr/bin/env bash
# Runs a command; on failure publishes the important output lines as a GitHub annotation
# (so the failure reason is readable through the API without downloading logs).
set -o pipefail
LOG=$(mktemp)
"$@" 2>&1 | tee "$LOG"
code=${PIPESTATUS[0]}
if [ "$code" -ne 0 ]; then
  { grep -E "error|Error|ERROR|FAIL|What went wrong|e: |Exception|isn't|undefined|Undefined" "$LOG" | grep -v "^\s*$" | head -40; echo "-----"; tail -25 "$LOG"; } \
    | cut -c1-300 | python3 -c "import sys;d=sys.stdin.read().replace('%','%25').replace('\r','').replace('\n','%0A');print('::error title=$1 failed::'+d[:30000])"
fi
exit $code
