#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""
mkdtboimg.py - Tool for creating Android DTBO images (magic: 0xd7b7ab1e).
"""

import sys
import os
import struct
import argparse

DT_TABLE_MAGIC = 0xd7b7ab1e
DT_TABLE_HDR_SIZE = 32
DT_ENTRY_SIZE = 20

def create_dtbo_image(output_path, dtb_paths, page_size=2048):
    entries = []
    current_dt_offset = ((DT_TABLE_HDR_SIZE + len(dtb_paths) * DT_ENTRY_SIZE + page_size - 1) // page_size) * page_size
    
    dt_blobs = []
    for path in dtb_paths:
        with open(path, 'rb') as f:
            data = f.read()
        dt_size = len(data)
        entries.append((dt_size, current_dt_offset, 0, 0, 0))
        dt_blobs.append((current_dt_offset, data))
        current_dt_offset = ((current_dt_offset + dt_size + page_size - 1) // page_size) * page_size

    total_size = current_dt_offset
    header = struct.pack(
        '>8I',
        DT_TABLE_MAGIC,
        total_size,
        DT_TABLE_HDR_SIZE,
        DT_ENTRY_SIZE,
        len(entries),
        DT_TABLE_HDR_SIZE,
        page_size,
        0
    )

    with open(output_path, 'wb') as f:
        f.write(header)
        for dt_size, offset, id_, rev, custom in entries:
            f.write(struct.pack('>5I', dt_size, offset, id_, rev, custom))
        
        for offset, data in dt_blobs:
            pad = offset - f.tell()
            if pad > 0:
                f.write(b'\x00' * pad)
            f.write(data)
            
        final_pad = total_size - f.tell()
        if final_pad > 0:
            f.write(b'\x00' * final_pad)

    print(f"Successfully created DTBO image: {output_path} ({os.path.getsize(output_path)} bytes)")

def main():
    parser = argparse.ArgumentParser(description="Create Android DTBO image from DTB files")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    create_parser = subparsers.add_parser("create")
    create_parser.add_argument("output", help="Output dtbo.img file path")
    create_parser.add_argument("--page_size", type=int, default=2048, help="Page alignment size (default: 2048)")
    create_parser.add_argument("dtb_files", nargs="+", help="Input .dtb files")

    args = parser.parse_args()
    if args.command == "create":
        create_dtbo_image(args.output, args.dtb_files, page_size=args.page_size)

if __name__ == "__main__":
    main()
