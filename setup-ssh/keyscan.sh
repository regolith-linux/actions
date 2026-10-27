#!/usr/bin/env bash
#
# Add the host keys of SSH_HOST to KNOWN_HOSTS.
#
# Every leg of a build matrix scans the server at about the same time, and the
# server's sshd drops connections it cannot take yet ("Connection closed by
# remote host"). ssh-keyscan opens one connection per key type, so a scan can
# come back with only some of the server's keys, and ssh then fails later with
# "Host key verification failed" if it negotiates a missing one. Each key type
# is therefore scanned on its own, and a scan that could not connect is retried
# with a growing, randomized delay. A type the server answered for but has no
# key of is skipped.

set -eo pipefail

: "${SSH_HOST:?}"

KNOWN_HOSTS="${KNOWN_HOSTS:-/home/regolith/.ssh/known_hosts}"
KEY_TYPES="${KEYSCAN_TYPES:-rsa ecdsa ed25519}"
ATTEMPTS="${KEYSCAN_RETRY_ATTEMPTS:-5}"
DELAY="${KEYSCAN_RETRY_DELAY:-10}"

found=0

for type in $KEY_TYPES; do
  attempt=1
  while true; do
    # depending on the version, the "# host:port SSH-2.0-..." banner comment
    # goes to stdout or stderr; hashed (-H) key lines start with "|1|"
    out=$(ssh-keyscan -H -t "$type" "$SSH_HOST" 2>&1 || true)
    keys=$(grep '^|1|' <<<"$out" || true)
    if [ -n "$keys" ]; then
      echo "$keys" >>"$KNOWN_HOSTS"
      found=1
      break
    fi
    if grep -q '^# .* SSH-' <<<"$out"; then
      echo "The server has no $type host key"
      break
    fi
    if [ "$attempt" -ge "$ATTEMPTS" ]; then
      echo "::error::ssh-keyscan could not get the $type host key of the server (attempt $attempt of $ATTEMPTS)"
      exit 1
    fi
    wait=$((DELAY * attempt + RANDOM % (DELAY + 1)))
    echo "::warning::ssh-keyscan could not get the $type host key of the server (attempt $attempt of $ATTEMPTS), retrying in ${wait}s"
    sleep "$wait"
    attempt=$((attempt + 1))
  done
done

if [ "$found" -eq 0 ]; then
  echo "::error::the server has none of these host key types: $KEY_TYPES"
  exit 1
fi
