# -*- coding: utf-8 -*-
"""把丢失的图片从备份图库回填到笔记里，保持 md 引用路径不变（不改写 md）。

工作逻辑：
    扫描 docs 下的 md -> 找出引用了但磁盘上不存在的图片 ->
    在备份库（默认 img_bak）里按文件名找回 -> 复制到 md 期望的位置

用法：
    python scripts/restore_images.py --dry-run                # 只看能救回多少
    python scripts/restore_images.py                          # 执行复制
    python scripts/restore_images.py --from img_bak img旧图 --docs-dir docs

安全：
    - 同名冲突时跳过并报告，绝不覆盖已有文件
    - 候选唯一才复制，多个候选时报告待定，避免错配
"""
import argparse
import hashlib
import os
import re
import shutil
from collections import defaultdict


def file_md5(path, block=1 << 20):
    h = hashlib.md5()
    with open(path, "rb") as fh:
        while True:
            b = fh.read(block)
            if not b:
                break
            h.update(b)
    return h.hexdigest()

LINK_RE = re.compile(r"!\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
IMG_EXT = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".bmp"}


def scan(md_root):
    """yield (md_path, 缺失图片的相对 target)"""
    for root, dirs, files in os.walk(md_root):
        dirs[:] = [d for d in dirs if d not in {".git", "_site", "export"}]
        for f in files:
            if not f.endswith(".md"):
                continue
            p = os.path.join(root, f)
            try:
                src = open(p, "r", encoding="utf-8", errors="ignore").read()
            except OSError:
                continue
            for m in LINK_RE.finditer(src):
                t = m.group(1).replace("\\", "/").split("#")[0].split("?")[0].strip()
                if not t or t.startswith(("http://", "https://", "data:")):
                    continue
                if os.path.splitext(t)[1].lower() not in IMG_EXT:
                    continue
                local = os.path.normpath(os.path.join(root, t))
                if not os.path.exists(local):
                    yield p, t, local


def index_pool(pools):
    table = defaultdict(list)
    for pool in pools:
        for root, dirs, files in os.walk(pool):
            dirs[:] = [d for d in dirs if d not in {".git"}]
            for f in files:
                if os.path.splitext(f)[1].lower() in IMG_EXT:
                    table[f].append(os.path.join(root, f))
    return table


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--docs-dir", default="docs")
    ap.add_argument("--from", dest="pools", nargs="+", default=["img_bak"])
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    pools = [p for p in args.pools if os.path.isdir(p)]
    if not pools:
        print("未找到任何备份图库：%s" % " ".join(args.pools))
        return
    table = index_pool(pools)
    print("备份图库：%s，共 %d 张候选" % (pools, sum(len(v) for v in table.values())))

    restored, ambiguous, hopeless = 0, 0, 0
    per_file = defaultdict(lambda: [0, 0])
    for md, target, local in scan(args.docs_dir):
        name = os.path.basename(local)
        cands = table.get(name)
        if not cands:
            hopeless += 1
            per_file[md][1] += 1
            continue
        if os.path.exists(local):
            continue
        if len(cands) > 1:
            digests = {file_md5(c) for c in cands}
            if len(digests) > 1:
                ambiguous += 1
                print("  [待定] %s -> 同名 %d 份内容不同，需人工确认" % (name, len(cands)))
                continue
            print("  [同名同图] %s -> %d 份内容一致，取第一份" % (name, len(cands)))
        if not args.dry_run:
            os.makedirs(os.path.dirname(local), exist_ok=True)
            shutil.copy2(cands[0], local)
        restored += 1
        per_file[md][0] += 1

    print("\n可回填 %d 张，同名待定 %d 张，备份库也没有 %d 张%s" % (
        restored, ambiguous, hopeless, "（预览，未复制）" if args.dry_run else ""))
    if not args.dry_run and restored:
        print("\n受益文件 top10：")
        for f, (ok, bad) in sorted(per_file.items(), key=lambda x: -x[1][0])[:10]:
            print("    %4d 补回 / %4d 无解   %s" % (ok, bad, f))


if __name__ == "__main__":
    main()
