#!/usr/bin/env bash
set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Server helper starting in: $BASEDIR"

find_server_pids() {
  while IFS= read -r pid; do
    [ -z "$pid" ] && continue
    [ -d "/proc/$pid" ] || continue
    local cwd
    cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
    if [[ "$cwd" == "$BASEDIR"* ]]; then
      echo "$pid"
      continue
    fi
    local cmd
    cmd="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
    if echo "$cmd" | grep -qiE 'run\.sh|paper|spigot|bungee|minecraft'; then
      echo "$pid"
    fi
  done < <(pgrep -f java || true)
}

echo "Detecting running Java/Paper/Spigot/Bungee processes..."
PIDS=()
while IFS= read -r pid; do
  PIDS+=("$pid")
done < <(find_server_pids)

if [ "${#PIDS[@]}" -eq 0 ]; then
  echo "No matching local Minecraft Java processes found."
else
  echo "Found ${#PIDS[@]} process(es): ${PIDS[*]}"
  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      echo "Sending SIGINT to PID $pid"
      kill -INT "$pid"
    else
      echo "PID $pid is not running"
    fi
  done

  echo "Waiting for processes to terminate..."
  sleep 5

  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      echo "PID $pid still running after SIGINT"
    fi
  done
fi

delete_session_locks() {
  local locks
  mapfile -t locks < <(find "$BASEDIR" -type f -name 'session.lock' 2>/dev/null || true)
  if [ "${#locks[@]}" -eq 0 ]; then
    echo "No session.lock files found."
    return
  fi

  echo "Found ${#locks[@]} session.lock file(s):"
  for lock in "${locks[@]}"; do
    echo "  $lock"
  done

  if [ "${DELETE_LOCKS:-}" = "1" ]; then
    echo "Deleting session.lock files."
    rm -f "${locks[@]}"
    return
  fi

  if [ -t 0 ] && [ -t 1 ]; then
    read -r -p "Delete these session.lock files? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      rm -f "${locks[@]}"
      echo "Deleted session.lock files."
    else
      echo "Skipping deletion of session.lock files."
    fi
  else
    echo "Non-interactive session; skipping session.lock deletion."
  fi
}

delete_session_locks

echo "Starting server with bash run.sh"
cd "$BASEDIR"
exec bash run.sh
