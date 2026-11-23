#!/bin/bash
set -o pipefail

if [[ $# -ne 4 || ! $2 =~ ^[1-9][0-9]*$ || ! $4 =~ ^[0-9]+$ ]]; then
  printf 'Usage: %s OUTPUT_FILE REQUEST_COUNT HTTPS_HOSTNAME HTTPS_PORT\n' "$0" >&2
  exit 2
fi

output=$1
count=$2
hostname=$3
port=$4
mkdir -p -- "$(dirname -- "$output")" || exit 1

for ((request = 1; request <= count; request++)); do
  printf '===== REQUEST %s =====\n' "$request"
  date -u '+%Y-%m-%dT%H:%M:%SZ'

  /usr/bin/curl --noproxy '*' \
    --connect-timeout 3 --max-time 15 \
    -sS -D - -o /dev/null \
    --resolve "$hostname:$port:127.0.0.1" \
    -w 'curl_http_code=%{http_code} total_seconds=%{time_total}\n' \
    "https://$hostname:$port/api/status"
  printf 'curl_exit_code=%s\n\n' "$?"

  if ((request < count)); then
    sleep 1
  fi
done 2>&1 | tee -- "$output"
