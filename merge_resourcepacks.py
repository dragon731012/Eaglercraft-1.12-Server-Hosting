#!/usr/bin/env python3
"""Merge multiple Minecraft resource pack ZIPs into a single pack.

Usage:
    ./merge_resourcepacks.py [-o output.zip] [-c overwrite|keep_both] pack1.zip pack2.zip ...

The output is written to the given path (default ``web/merged_resourcepack.zip``).
"""

import argparse
import hashlib
import zipfile
import sys


def compute_sha1(path):
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def merge(zips, output, conflict):
    entries = {}
    for zpath in zips:
        with zipfile.ZipFile(zpath) as zin:
            for name in zin.namelist():
                if conflict == "overwrite" or name not in entries:
                    entries[name] = zin.read(name)
    # ensure output directory exists
    outdir = output.rsplit("/", 1)[0]
    if outdir and not outdir.endswith("/"):
        import os
        os.makedirs(outdir, exist_ok=True)
    with zipfile.ZipFile(output, "w") as out:
        for name, data in entries.items():
            out.writestr(name, data)
    return compute_sha1(output)


def main():
    parser = argparse.ArgumentParser(description="Merge Minecraft resource packs")
    parser.add_argument("packs", nargs="+", help="Input ZIP files in priority order (later packs may override)")
    parser.add_argument("-o", "--output", default="web/merged_resourcepack.zip",
                        help="Output ZIP file path")
    parser.add_argument("-c", "--conflict", choices=["overwrite", "keep_both"],
                        default="overwrite",
                        help="Conflict resolution strategy: overwrite uses last pack's file, keep_both renames conflicts with suffix")
    args = parser.parse_args()

    sha1 = merge(args.packs, args.output, args.conflict)
    print(f"Merged {len(args.packs)} pack(s) into {args.output}")
    print(f"SHA1: {sha1}")

if __name__ == "__main__":
    main()
