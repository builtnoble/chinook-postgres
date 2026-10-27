#!/bin/sh
# Start an image and verify it comes up.
# Usage: tests/smoke-test.sh <image> [docker run args...]
#   e.g. tests/smoke-test.sh chinook-postgres:test -e POSTGRES_PASSWORD=test
#
# If the image defines a HEALTHCHECK, waits until it reports "healthy".
# Otherwise, checks the container is still running after a short grace period.
# Env: SMOKE_TIMEOUT (seconds to wait for healthy, default 60)
set -eu

IMAGE=${1:?usage: smoke-test.sh <image> [docker run args...]}
shift

TIMEOUT=${SMOKE_TIMEOUT:-60}
NAME="smoke-$$"

cleanup() {
    docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

fail() {
    echo "FAIL: $1" >&2
    echo "--- container logs ---" >&2
    docker logs "$NAME" >&2 || true
    exit 1
}

docker run -d --name "$NAME" "$@" "$IMAGE" >/dev/null

if [ "$(docker inspect -f '{{if .Config.Healthcheck}}yes{{end}}' "$NAME")" = "yes" ]; then
    elapsed=0
    while [ "$elapsed" -lt "$TIMEOUT" ]; do
        status=$(docker inspect -f '{{.State.Health.Status}}' "$NAME")
        [ "$status" = "healthy" ] && { echo "OK: healthy after ~${elapsed}s"; exit 0; }
        [ "$(docker inspect -f '{{.State.Running}}' "$NAME")" = "true" ] || fail "container exited before becoming healthy"
        sleep 2
        elapsed=$((elapsed + 2))
    done
    fail "not healthy after ${TIMEOUT}s (last status: $status)"
fi

echo "No HEALTHCHECK defined; checking the container stays running for 5s"
sleep 5
[ "$(docker inspect -f '{{.State.Running}}' "$NAME")" = "true" ] || fail "container is not running"
echo "OK: still running"
