# -*- coding: utf-8 -*-
"""自动修复 docs 里可机器还原的错链，改写原文前会自动备份。

处理三类：
    1. ROOT-IMG  引用 img/xxx.png，图片其实在 docs/img/xxx.png
                 -> 改成 /img/xxx.png（MkDocs 根绝对路径，避免层级跳错）
    2. BACKSLASH Windows 反斜杠 .\img\a\b.png  -> 改成 /img/a/b.png
    3. MD-ALIAS  链接到已改名的 md（如 01-Student.md 实为 4-3-1-Student.md）
                 -> 改成同目录同 basename 后缀的正确文件名

用法：
    python scripts/fix_links.py --dry-run      # 只报告，不改文件
    python scripts/fix_links.py                # 执行修复（生成 .bak 备份）
"""
import argparse
import os
import re
import shutil

LINK_RE = re.compile(r"!?\[([^\]]*)\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")


def build_resolve_table(docs_dir):
    """{basename: [相对 docs 根的路径]} 用于找回错位目标。"""
    table = {}
    for root, dirs, files in os.walk(docs_dir):
        dirs[:] = [d for d in dirs if d not in {".git", "_site"}]
        for f in files:
            rel = os.path.relpath(os.path.join(root, f), docs_dir).replace("\\", "/")
            table.setdefault(f, []).append(rel)
    return table


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--docs-dir", default="docs")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--no-backup", action="store_true")
    args = ap.parse_args()

    table = build_resolve_table(args.docs_dir)
    changed_files, total = 0, 0

    for root, dirs, files in os.walk(args.docs_dir):
        dirs[:] = [d for d in dirs if d not in {".git", "_site", "export", "img_bak"}]
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(root, name)
            with open(path, "r", encoding="utf-8", errors="ignore") as fh:
                src = fh.read()
            if "[" not in src:
                continue

            hits = []

            def repl(m):
                label, target = m.group(1), m.group(2)
                if target.startswith(("http://", "https://", "mailto:", "#")):
                    return m.group(0)
                t = target.split("#")[0].split("?")[0]
                if not t:
                    return m.group(0)
                local = os.path.normpath(os.path.join(root, t))
                if os.path.exists(local):
                    return m.group(0)
                bare = os.path.basename(t.replace("\\", "/"))
                cands = table.get(bare)
                if not cands:
                    return m.group(0)
                # 优先选路径尾部的子路径一致者（img/ByteFlow/x.jpg -> /img/ByteFlow/x.jpg）
                want = "/" + t.replace("\\", "/").lstrip("./")
                pick = None
                for c in cands:
                    if ("/" + c) == want:
                        pick = c
                        break
                if pick is None:
                    pick = cands[0]
                new = "/" + pick
                hits.append((t, new))
                frag = ""
                if "#" in target:
                    frag = "#" + target.split("#", 1)[1]
                return "[%s](%s%s)" % (label, new, frag)

            out = LINK_RE.sub(repl, src)
            if not hits:
                continue
            changed_files += 1
            total += len(hits)
            print("[%s] %s  修复 %d 处" % ("预览" if args.dry_run else "写入", path, len(hits)))
            for old, new in hits[:3]:
                print("      %s  ->  %s" % (old, new))
            if len(hits) > 3:
                print("      ... 其余 %d 处" % (len(hits) - 3))
            if not args.dry_run:
                if not args.no_backup:
                    shutil.copy2(path, path + ".bak")
                with open(path, "w", encoding="utf-8") as fh:
                    fh.write(out)

    print("\n合计：%d 个文件、%d 处链接%s" % (
        changed_files, total, "（预览模式，未改盘）" if args.dry_run else ""))


if __name__ == "__main__":
    main()
