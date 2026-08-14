#!/usr/bin/env bash
# Upload demo performer photos to MinIO via the velvet Docker network.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"

if ! docker compose ps minio --status running >/dev/null 2>&1; then
  echo "Starting minio…"
  docker compose up -d minio minio-init
  sleep 3
fi

NET="$(docker compose ps -q minio | xargs docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | head -1)"
if [[ -z "$NET" ]]; then
  echo "Could not resolve compose network for minio." >&2
  exit 1
fi

echo "Running photo seeder on network: $NET"
docker run --rm \
  --network "$NET" \
  -v "$ROOT/services/api/scripts:/scripts" \
  -e S3_ENDPOINT=http://minio:9000 \
  -e S3_ACCESS_KEY=velvet \
  -e S3_SECRET_KEY=velvetsecret \
  -e S3_BUCKET=velvet \
  python:3.12-slim \
  bash -lc 'pip install -q boto3 requests pillow && python /scripts/seed_demo_photos.py'
