#!/usr/bin/env python3
"""Fold noctalia's live settings.toml overrides into noctaliaSettings in default.nix.

noctalia writes user-made changes (GUI settings, panel edits) as a sparse
overlay to ~/.local/state/noctalia/settings.toml, layered at runtime on top
of whatever home-manager wrote to ~/.config/noctalia/config.toml. This script
computes that same overlay (current nix-declared settings + live overrides)
and rewrites the `noctaliaSettings = { ... };` block in default.nix to match,
so the overlay becomes the new committed default.

A few keys are intentionally excluded because they are runtime/schema state,
not user settings -- see EXCLUDE_PATHS below. Extend that list if noctalia
starts writing other transient keys into settings.toml.

Known limitation: this rewrites the whole settings block from merged data, so
hand-written Nix niceties in the current block (e.g. "${wallpaperDir}/..."
string interpolation, dotted-attr shorthand like `bar.default = {...}`,
comments) are replaced by their fully-nested, literal-value equivalents.
Values are unaffected -- only formatting/DRY-ness of the regenerated block.
"""

import argparse
import json
import subprocess
import sys
import tomllib
from pathlib import Path

HOST = "osgiliath"
HM_USER = "tillo"
NIX_FILE_REL = "home/modules/niri/noctalia/default.nix"
LIVE_SETTINGS = Path.home() / ".local/state/noctalia/settings.toml"
BLOCK_NAME = "noctaliaSettings"

# Dotted paths that are noctalia-managed runtime/schema state, not settings,
# and must never be copied from settings.toml into the Nix source.
EXCLUDE_PATHS = [
    ["config_version"],
    ["wallpaper", "last"],
]

_MISSING = object()


def repo_root() -> Path:
    out = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=Path(__file__).resolve().parent,
        capture_output=True,
        text=True,
        check=True,
    )
    return Path(out.stdout.strip())


def strip_excluded(data: dict) -> dict:
    for path in EXCLUDE_PATHS:
        node = data
        for key in path[:-1]:
            if not isinstance(node, dict) or key not in node:
                node = None
                break
            node = node[key]
        if isinstance(node, dict):
            node.pop(path[-1], None)
    return data


def deep_merge(base, override):
    if isinstance(base, dict) and isinstance(override, dict):
        result = dict(base)
        for key, value in override.items():
            result[key] = deep_merge(result.get(key, _MISSING), value)
        return result
    return override if override is not _MISSING else base


def iter_leaf_diffs(old, new, prefix=""):
    if isinstance(old, dict) and isinstance(new, dict):
        for key in sorted(set(old) | set(new)):
            child_prefix = f"{prefix}.{key}" if prefix else key
            yield from iter_leaf_diffs(
                old.get(key, _MISSING), new.get(key, _MISSING), child_prefix
            )
    elif old != new:
        yield (prefix, old, new)


def nix_eval_json(root: Path, attr: str):
    out = subprocess.run(
        ["nix", "eval", "--json", f".#{attr}"],
        cwd=root,
        capture_output=True,
        text=True,
    )
    if out.returncode != 0:
        sys.exit(f"nix eval failed for {attr}:\n{out.stderr}")
    return json.loads(out.stdout)


def nix_pretty_print(root: Path, data) -> str:
    with_tmp = root / ".sync-settings-merged.json"
    with_tmp.write_text(json.dumps(data))
    try:
        expr = f"""
          let
            pkgs = (builtins.getFlake "{root}").inputs.nixpkgs.legacyPackages.x86_64-linux;
            data = builtins.fromJSON (builtins.readFile "{with_tmp}");
          in
          pkgs.lib.generators.toPretty {{ multiline = true; }} data
        """
        out = subprocess.run(
            ["nix", "eval", "--raw", "--impure", "--expr", expr],
            cwd=root,
            capture_output=True,
            text=True,
        )
        if out.returncode != 0:
            sys.exit(f"nix pretty-print failed:\n{out.stderr}")
        return out.stdout
    finally:
        with_tmp.unlink(missing_ok=True)


def replace_block(source: str, block_name: str, new_value: str) -> str:
    marker = f"{block_name} = {{"
    start = source.find(marker)
    if start == -1:
        sys.exit(f"could not find '{marker}' in {NIX_FILE_REL}")
    brace_start = start + len(marker) - 1  # index of the opening '{'
    depth = 0
    in_string = False
    escaped = False
    end = None
    for i in range(brace_start, len(source)):
        ch = source[i]
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i
                break
    if end is None:
        sys.exit(f"unbalanced braces while scanning '{block_name}' in {NIX_FILE_REL}")
    # Consume a trailing ';' right after the closing brace, if present.
    tail = end + 1
    if tail < len(source) and source[tail] == ";":
        tail += 1
    return source[:start] + f"{block_name} = {new_value.strip()};" + source[tail:]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print the diff but don't touch default.nix",
    )
    parser.add_argument(
        "--skip-build",
        action="store_true",
        help="skip the post-write `nix build` validation step",
    )
    args = parser.parse_args()

    root = repo_root()
    nix_file = root / NIX_FILE_REL

    if not LIVE_SETTINGS.exists():
        sys.exit(f"no live settings found at {LIVE_SETTINGS}")

    with LIVE_SETTINGS.open("rb") as f:
        live = tomllib.load(f)
    strip_excluded(live)

    base_attr = f"nixosConfigurations.{HOST}.config.home-manager.users.{HM_USER}.programs.noctalia.settings"
    base = nix_eval_json(root, base_attr)

    merged = deep_merge(base, live)

    diffs = list(iter_leaf_diffs(base, merged))
    if not diffs:
        print("settings.toml has no changes beyond what's already in default.nix.")
        return

    print(f"{len(diffs)} changed/added key(s):")
    for path, old, new in diffs:
        old_repr = "<absent>" if old is _MISSING else json.dumps(old)
        print(f"  {path}: {old_repr} -> {json.dumps(new)}")

    if args.dry_run:
        print("\n--dry-run: default.nix left untouched.")
        return

    pretty = nix_pretty_print(root, merged)

    original_text = nix_file.read_text()
    new_text = replace_block(original_text, BLOCK_NAME, pretty)
    nix_file.write_text(new_text)
    print(f"\nRewrote {BLOCK_NAME} in {NIX_FILE_REL}.")

    if args.skip_build:
        return

    print(f"Validating with `nix build .#nixosConfigurations.{HOST}...`")
    build = subprocess.run(
        [
            "nix",
            "build",
            f".#nixosConfigurations.{HOST}.config.system.build.toplevel",
            "--no-link",
        ],
        cwd=root,
        capture_output=True,
        text=True,
    )
    if build.returncode != 0:
        nix_file.write_text(original_text)
        sys.exit(
            "Build failed after rewrite; reverted default.nix to its prior "
            f"content.\n\n{build.stderr}"
        )
    print("Build OK. Review the diff (`git diff`) before rebuilding/switching.")


if __name__ == "__main__":
    main()
