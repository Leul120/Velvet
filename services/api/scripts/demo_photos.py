"""Shared helpers for demo performer profile photos stored in MinIO."""

from __future__ import annotations

WOMEN = 60
PHOTOS_PER_WOMAN = 3


def woman_id(n: int) -> str:
    return f"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb{n:02d}"


def demo_photo_uuid(woman_n: int, photo_i: int) -> str:
    """Deterministic object id — must match seed_demo_photos.py uploads."""
    return f"eeeeeeee-eeee-4eee-8eee-eeee{woman_n:04d}{photo_i:04d}"


def demo_photo_key(woman_n: int, photo_i: int) -> str:
    return f"profile/{woman_id(woman_n)}/{demo_photo_uuid(woman_n, photo_i)}.jpg"


def demo_photo_url(woman_n: int, photo_i: int) -> str:
    return f"/v1/media/{demo_photo_key(woman_n, photo_i)}"


def woman_photos_json(woman_n: int) -> str:
    urls = [demo_photo_url(woman_n, i) for i in range(PHOTOS_PER_WOMAN)]
    inner = ",".join(f'"{u}"' for u in urls)
    return f"'[{inner}]'"
