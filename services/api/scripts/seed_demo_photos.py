#!/usr/bin/env python3
"""
Download beach portrait photos from Unsplash and upload to MinIO for demo performers.

Keys follow the live upload layout: profile/{userId}/{uuid}.jpg
Stored URLs: /v1/media/profile/{userId}/{uuid}.jpg

Run from repo root (needs Docker + velvet stack up):
  ./services/api/scripts/run_seed_demo_photos.sh

Or directly on the compose network:
  docker run --rm --network velvet_default \\
    -v "$PWD/services/api/scripts:/scripts" \\
    python:3.12-slim bash -lc \\
    'pip install -q boto3 requests && python /scripts/seed_demo_photos.py'
"""

from __future__ import annotations

import io
import json
import os
import sys
import time
import urllib.parse
from pathlib import Path

import boto3
import requests
from botocore.config import Config
from PIL import Image

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from demo_photos import (  # noqa: E402
    PHOTOS_PER_WOMAN,
    WOMEN,
    demo_photo_key,
    demo_photo_url,
)

SEARCH_QUERIES = [
    "beautiful woman beach portrait",
    "woman beach sunset portrait",
    "tropical beach woman summer",
    "woman ocean bikini portrait",
    "beach fashion woman portrait",
    "woman seaside vacation portrait",
    "beach model woman portrait",
    "woman sand ocean portrait",
]

S3_ENDPOINT = os.environ.get("S3_ENDPOINT", "http://minio:9000")
S3_ACCESS_KEY = os.environ.get("S3_ACCESS_KEY", "velvet")
S3_SECRET_KEY = os.environ.get("S3_SECRET_KEY", "velvetsecret")
S3_BUCKET = os.environ.get("S3_BUCKET", "velvet")
MANIFEST_PATH = SCRIPT_DIR / "demo_photo_manifest.json"
TARGET_W = 900
TARGET_H = 1200
TOTAL = WOMEN * PHOTOS_PER_WOMAN


def fetch_unsplash_pool() -> list[str]:
    """Collect direct image URLs via Unsplash's public search API."""
    seen: set[str] = set()
    urls: list[str] = []

    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": "VelvetDemoSeeder/1.0 (+https://github.com/velvet)",
            "Accept": "application/json",
        }
    )

    for query in SEARCH_QUERIES:
        page = 1
        while len(urls) < TOTAL + 40 and page <= 8:
            params = urllib.parse.urlencode(
                {"query": query, "per_page": 30, "page": page, "orientation": "portrait"}
            )
            resp = session.get(
                f"https://unsplash.com/napi/search/photos?{params}",
                timeout=30,
            )
            if resp.status_code != 200:
                print(f"  search failed ({query} p{page}): HTTP {resp.status_code}", file=sys.stderr)
                break
            results = resp.json().get("results") or []
            if not results:
                break
            for item in results:
                raw = (item.get("urls") or {}).get("regular") or (item.get("urls") or {}).get("full")
                if not raw:
                    continue
                # Normalize to a stable download size.
                parsed = urllib.parse.urlparse(raw)
                host = parsed.netloc
                if "unsplash.com" not in host:
                    continue
                base = f"{parsed.scheme}://{host}{parsed.path}"
                download = f"{base}?auto=format&fit=crop&w={TARGET_W}&h={TARGET_H}&q=85"
                if download not in seen:
                    seen.add(download)
                    urls.append(download)
            page += 1
            time.sleep(0.35)
        if len(urls) >= TOTAL + 40:
            break

    if len(urls) < TOTAL:
        raise RuntimeError(f"Need {TOTAL} unique photos, only found {len(urls)} from Unsplash.")
    return urls


def normalize_image(data: bytes) -> bytes:
    """Crop/resize to a consistent portrait for listing cards."""
    with Image.open(io.BytesIO(data)) as img:
        img = img.convert("RGB")
        w, h = img.size
        target_ratio = TARGET_W / TARGET_H
        current_ratio = w / h
        if current_ratio > target_ratio:
            new_w = int(h * target_ratio)
            left = (w - new_w) // 2
            img = img.crop((left, 0, left + new_w, h))
        else:
            new_h = int(w / target_ratio)
            top = (h - new_h) // 2
            img = img.crop((0, top, w, top + new_h))
        img = img.resize((TARGET_W, TARGET_H), Image.Resampling.LANCZOS)
        out = io.BytesIO()
        img.save(out, format="JPEG", quality=88, optimize=True)
        return out.getvalue()


def s3_client():
    # Newer botocore default checksums break PutObject against MinIO (HTTP 403).
    return boto3.client(
        "s3",
        endpoint_url=S3_ENDPOINT,
        aws_access_key_id=S3_ACCESS_KEY,
        aws_secret_access_key=S3_SECRET_KEY,
        region_name="us-east-1",
        config=Config(
            signature_version="s3v4",
            s3={"addressing_style": "path"},
            request_checksum_calculation="when_required",
            response_checksum_validation="when_required",
        ),
    )


def ensure_bucket(client) -> None:
    try:
        client.head_bucket(Bucket=S3_BUCKET)
    except Exception:
        client.create_bucket(Bucket=S3_BUCKET)


def upload_photo(client, key: str, body: bytes) -> None:
    client.put_object(
        Bucket=S3_BUCKET,
        Key=key,
        Body=body,
        ContentType="image/jpeg",
        CacheControl="public, max-age=86400",
    )


def picsum_pool() -> list[str]:
    """Deterministic portrait placeholders when Unsplash is blocked."""
    return [
        f"https://picsum.photos/seed/velvet{n:04d}/900/1200.jpg"
        for n in range(1, TOTAL + 80)
    ]


def main() -> None:
    print(f"Collecting {TOTAL} Unsplash beach portraits…")
    try:
        pool = fetch_unsplash_pool()
        print(f"  found {len(pool)} candidates")
    except Exception as exc:
        print(f"  Unsplash unavailable ({exc}); falling back to Picsum portraits", file=sys.stderr)
        pool = picsum_pool()
        print(f"  using {len(pool)} Picsum candidates")

    client = s3_client()
    ensure_bucket(client)

    session = requests.Session()
    session.headers["User-Agent"] = "VelvetDemoSeeder/1.0"

    manifest: dict[str, object] = {
        "version": 1,
        "bucket": S3_BUCKET,
        "women": {},
        "source": "unsplash" if "unsplash.com" in (pool[0] if pool else "") else "picsum",
    }
    cursor = 0
    uploaded = 0

    for woman_n in range(1, WOMEN + 1):
        urls: list[str] = []
        for photo_i in range(PHOTOS_PER_WOMAN):
            key = demo_photo_key(woman_n, photo_i)
            url = demo_photo_url(woman_n, photo_i)

            body = None
            while cursor < len(pool):
                src = pool[cursor]
                cursor += 1
                try:
                    resp = session.get(src, timeout=45, allow_redirects=True)
                    resp.raise_for_status()
                    if len(resp.content) < 8000:
                        continue
                    body = normalize_image(resp.content)
                    break
                except Exception as exc:
                    print(f"  skip download: {exc}", file=sys.stderr)
                    body = None
            if body is None:
                raise RuntimeError("Ran out of image candidates while downloading.")

            upload_photo(client, key, body)
            urls.append(url)
            uploaded += 1
            if uploaded % 15 == 0 or uploaded == TOTAL:
                print(f"  uploaded {uploaded}/{TOTAL}")

        manifest["women"][str(woman_n)] = urls

    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Done — {uploaded} photos in s3://{S3_BUCKET}/profile/")
    print(f"Manifest: {MANIFEST_PATH}")


if __name__ == "__main__":
    main()
