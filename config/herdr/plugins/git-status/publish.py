#!/usr/bin/env python3
"""
Publishes a compact branch list + dirty marker as the `$local_branches`
custom token, readable from `[ui.sidebar.spaces].rows` in config.toml.

Token format (single line, ~30 chars):
  "<current>* <other1> <other2> …"
  * marks the currently checked-out branch.
  Trailing "±N" is the staged+unstaged+untracked delta when the working
  tree is dirty (e.g.  "main* dev  feat/x  ±2").

Runs idempotently inside herdr events. Exits 0 on any failure so the
sidebar never blanks out due to a non-git directory.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

MAX_BRANCHES = 8
MAX_LEN = 30


def run(args: list[str], cwd: Path) -> str:
    try:
        out = subprocess.run(
            args,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        )
        return out.stdout.strip()
    except Exception:
        return ""


def find_repo(cwd: Path) -> Path | None:
    p = cwd
    for _ in range(8):
        if (p / ".git").exists():
            return p
        parent = p.parent
        if parent == p:
            return None
        p = parent
    return None


def list_branches(repo: Path) -> tuple[str, list[str]]:
    out = run(
        ["git", "for-each-ref", "--format=%(HEAD)%(refname:short)", "refs/heads"],
        repo,
    )
    current = ""
    others: list[str] = []
    for line in out.splitlines():
        if not line:
            continue
        if line.startswith("*"):
            current = line[1:].strip()
        else:
            others.append(line.strip())
    return current, others


def dirty_count(repo: Path) -> int:
    out = run(["git", "status", "--porcelain", "--untracked-files=normal", "-z"], repo)
    if not out:
        return 0
    # NUL-separated; each non-empty entry is one path with status
    return sum(1 for entry in out.split("\0") if entry)


def build_token(cwd: Path) -> str:
    repo = find_repo(cwd)
    if not repo:
        return ""

    current, others = list_branches(repo)
    parts: list[str] = []
    if current:
        parts.append(f"{current}*")
    for b in others:
        if b == current:
            continue
        parts.append(b)
        if len(parts) >= MAX_BRANCHES:
            break

    token = " ".join(parts)
    n = dirty_count(repo)
    if n:
        token = f"{token} ±{n}"
    if len(token) > MAX_LEN:
        token = token[: MAX_LEN - 1] + "…"
    return token


def main() -> int:
    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    pane_id = os.environ.get("HERDR_PANE_ID")
    if not pane_id:
        return 0

    try:
        ctx = json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON", "{}"))
    except Exception:
        ctx = {}

    cwd_str = ctx.get("focused_pane_cwd") or os.environ.get("HOME") or "/"
    cwd = Path(cwd_str)
    token = build_token(cwd)

    args = [
        herdr, "pane", "report-metadata", pane_id,
        "--source", "git-status",
    ]
    if token:
        args += ["--token", f"local_branches={token}"]
    else:
        args += ["--clear-token", "local_branches"]

    try:
        subprocess.run(args, capture_output=True, timeout=2, check=False)
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
