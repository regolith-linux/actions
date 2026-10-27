#!/usr/bin/env bash
#
# Tests for setup-ssh/keyscan.sh.
#
# ssh-keyscan is replaced by a stub on PATH. It is called as
# `ssh-keyscan -H -t <type> <host>` and, like the real one, prints the
# server's banner as a comment and the hashed key of that type. The stub can
# drop the connection a given number of times (all types, or one type only),
# and can play a server without keys of some types.
#
# Requires: bash
#
# Usage: setup-ssh/tests/test-keyscan.sh

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
KEYSCAN="${SCRIPT_DIR}/../keyscan.sh"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

FAILED=0

pass() {
  echo -e "\033[0;32mPASS\033[0m: $1"
}

fail() {
  echo -e "\033[0;31mFAIL\033[0m: $1"
  FAILED=1
}

# run keyscan.sh with the given extra environment; sets RC and OUT
run_case() {
  rm -rf "${WORK_DIR:?}/bin" "$WORK_DIR"/count.* "$WORK_DIR/calls" "$WORK_DIR/known_hosts"
  mkdir -p "$WORK_DIR/bin"
  echo "existing-entry" >"$WORK_DIR/known_hosts"
  cat >"$WORK_DIR/bin/ssh-keyscan" <<STUB
#!/usr/bin/env bash
[ "\$1" == "-H" ] && [ "\$2" == "-t" ] || { echo "unexpected arguments: \$*" >&2; exit 2; }
type=\$3; host=\$4
echo "\$type" >>"$WORK_DIR/calls"
n=\$(cat "$WORK_DIR/count.\$type" 2>/dev/null || echo 0)
echo \$((n + 1)) >"$WORK_DIR/count.\$type"
if [ -z "\${STUB_FAIL_TYPE:-}" ] || [ "\$STUB_FAIL_TYPE" == "\$type" ]; then
  if [ "\$n" -lt "\${STUB_FAIL_TIMES:-0}" ]; then
    echo "\$host: Connection closed by remote host" >&2
    exit 1
  fi
fi
# newer ssh-keyscan prints the banner on stdout, older ones on stderr
if [ "\${STUB_BANNER_STDOUT:-}" == "true" ]; then
  echo "# \$host:22 SSH-2.0-OpenSSH_10.2p1"
else
  echo "# \$host:22 SSH-2.0-OpenSSH_9.6p1" >&2
fi
case " \${STUB_NO_TYPES:-} " in
  *" \$type "*) exit 0 ;;
esac
echo "|1|c2FsdA==|aGFzaA== key-\$type AAAA"
STUB
  chmod +x "$WORK_DIR/bin/ssh-keyscan"

  RC=0
  OUT=$(env PATH="$WORK_DIR/bin:$PATH" \
    SSH_HOST="host" \
    KNOWN_HOSTS="$WORK_DIR/known_hosts" \
    KEYSCAN_RETRY_DELAY=0 \
    "$@" \
    "$KEYSCAN" 2>&1) || RC=$?
}

calls() {
  if [ -f "$WORK_DIR/calls" ]; then wc -l <"$WORK_DIR/calls"; else echo 0; fi
}

keys() {
  grep -o 'key-[a-z0-9]*' "$WORK_DIR/known_hosts" | tr '\n' ' '
}

# 1. every type answers: one scan per type, all keys appended after the
#    existing entries, no banner comments in known_hosts
run_case STUB_BANNER_STDOUT=true
if [ "$RC" -eq 0 ] && [ "$(calls)" -eq 3 ] && [ "$(keys)" == "key-rsa key-ecdsa key-ed25519 " ] &&
  [ "$(head -1 "$WORK_DIR/known_hosts")" == "existing-entry" ] && ! grep -q '^#' "$WORK_DIR/known_hosts"; then
  pass "appends one key per type"
else
  fail "appends one key per type (rc=$RC, calls=$(calls), keys: $(keys))"
fi

# 2. dropped connections are retried (each type is dropped twice)
run_case STUB_FAIL_TIMES=2
if [ "$RC" -eq 0 ] && [ "$(calls)" -eq 9 ] && [ "$(keys)" == "key-rsa key-ecdsa key-ed25519 " ] &&
  grep -q "attempt 2 of 5" <<<"$OUT"; then
  pass "retries until the server answers"
else
  fail "retries until the server answers (rc=$RC, calls=$(calls), keys: $(keys))"
fi

# 3. one type dropped while the others answer: that type is still fetched
run_case STUB_FAIL_TYPE=ed25519 STUB_FAIL_TIMES=2 STUB_BANNER_STDOUT=true
if [ "$RC" -eq 0 ] && [ "$(calls)" -eq 5 ] && [ "$(keys)" == "key-rsa key-ecdsa key-ed25519 " ]; then
  pass "fetches a type whose connection was dropped"
else
  fail "fetches a type whose connection was dropped (rc=$RC, calls=$(calls), keys: $(keys))"
fi

# 4. a type the server has no key of is skipped without retrying
run_case STUB_NO_TYPES=ecdsa
if [ "$RC" -eq 0 ] && [ "$(calls)" -eq 3 ] && [ "$(keys)" == "key-rsa key-ed25519 " ] &&
  grep -q "The server has no ecdsa host key" <<<"$OUT"; then
  pass "skips a type the server has no key of"
else
  fail "skips a type the server has no key of (rc=$RC, calls=$(calls), keys: $(keys))"
fi

# 5. gives up after the last attempt
run_case STUB_FAIL_TYPE=rsa STUB_FAIL_TIMES=10 KEYSCAN_RETRY_ATTEMPTS=3
if [ "$RC" -eq 1 ] && [ "$(calls)" -eq 3 ] && [ "$(keys)" == "" ] &&
  grep -q "::error::ssh-keyscan could not get the rsa host key of the server (attempt 3 of 3)" <<<"$OUT"; then
  pass "gives up after the last attempt"
else
  fail "gives up after the last attempt (rc=$RC, calls=$(calls), keys: $(keys))"
fi

# 6. fails if the server has none of the types
run_case STUB_NO_TYPES="rsa ecdsa ed25519" STUB_BANNER_STDOUT=true
if [ "$RC" -eq 1 ] && [ "$(calls)" -eq 3 ] && [ "$(keys)" == "" ] && ! grep -q '^#' "$WORK_DIR/known_hosts"; then
  pass "fails when the server has none of the types"
else
  fail "fails when the server has none of the types (rc=$RC, calls=$(calls), keys: $(keys))"
fi

exit "$FAILED"
