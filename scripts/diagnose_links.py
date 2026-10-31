# -*- coding: utf-8 -*-
"""诊断 MkDocs 构建出来的缺失链接，判断每一条能否自动修复。

用法：
    python scripts/diagnose_links.py            # 诊断当前仓库
    python scripts/diagnose_links.py --docs-dir docs --report report.txt

分类：
    MISSING_FILE      目标文件磁盘上确实不存在，但同名文件在别处能找到 -> 可修复
    MISSING_TOTAL     同名文件在整个仓库都找不到                     -> 需人工补图
    WRONG_CASE        路径存在但大小写不一致                          -> 部署到 Linux 会挂
    BACKSLASH         Windows 反斜杠路径，网页上必然失效               -> 可自动替换
    OK_TOO             target is outside docs tree
"""
import argparse
import os
import re
import sys
from collections import defaultdict

LINK_RE = re.compile(r"\[([^\]]*)\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
IMG_EXT = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".bmp"}


def iter_md(docs_dir):
    for root, dirs, files in os.walk(docs_dir):
        dirs[:] = [d for d in dirs if d not in {".git", "_site", "export", "img_bak"}]
        for f in files:
            if f.endswith(".md"):
                yield os.path.join(root, f)


def build_index(docs_dir):
    """basename -> [绝对路径]，用于在别处找回图片。"""
    index = defaultdict(list)
    for root, dirs, files in os.walk(docs_dir):
        dirs[:] = [d for d in dirs if d not in {".git", "_site"}]
        for f in files:
            index[f].append(os.path.join(root, f))
    return index


def norm_join(base_dir, target):
    """把 markdown 里的链接 target 解析成本地路径（处理反斜杠与 ..）。"""
    t = target.replace("\\", "/").split("#")[0].split("?")[0].strip()
    if not t or t.startswith(("http://", "https://", "mailto:", "tel:")):
        return None, False
    if t.startswith("/"):
        return None, True
    had_backslash = "\\" in target
    return os.path.normpath(os.path.join(base_dir, t)), had_backslash


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--docs-dir", default="docs")
    ap.add_argument("--repo-root", default=".")
    ap.add_argument("--report", default=None)
    args = ap.parse_args()

    if not os.path.isdir(args.docs_dir):
        sys.exit("错误：找不到 docs 目录 %s" % args.docs_dir)

    index = build_index(args.repo_root)
    stats = defaultdict(list)

    for md in iter_md(args.docs_dir):
        base = os.path.dirname(md)
        with open(md, "r", encoding="utf-8", errors="ignore") as fh:
            for _m in LINK_RE.finditer(fh.read()):
                target = _m.group(2)
                path, off_root = norm_join(base, target)
                if off_root:
                    stats["OUT_OF_TREE"].append((md, target))
                    continue
                if path is None:
                    continue
                if os.path.exists(path):
                    continue
                name = os.path.basename(path)
                if "\\" in target:
                    stats["BACKSLASH"].append((md, target))
                elif index.get(name):
                    stats["MISSING_FILE"].append((md, target, index[name][0]))
                else:
                    stats["MISSING_TOTAL"].append((md, target))

    lines = []
    total = sum(len(v) for v in stats.values())
    lines.append("=" * 72)
    lines.append("缺失链接总数：%d" % total)
    lines.append("=" * 72)
    for kind in ("MISSING_FILE", "BACKSLASH", "MISSING_TOTAL", "OUT_OF_TREE"):
        items = stats[kind]
        if not items:
            continue
        label = {
            "MISSING_FILE": "可修复（同名文件在别处找到）",
            "BACKSLASH": "可修复（Windows 反斜杠路径）",
            "MISSING_TOTAL": "需人工补图（全仓库无同名文件）",
            "OUT_OF_TREE": "指向 docs 之外（无法解析）",
        }[kind]
        lines.append("\n[%s]  %d 条" % (label, len(items)))
        per_file = defaultdict(int)
        for it in items:
            per_file[it[0]] += 1
        for f, c in sorted(per_file.items(), key=lambda x: -x[1])[:15]:
            lines.append("    %4d  %s" % (c, f))
        lines.append("    样例：")
        for it in items[:5]:
            if kind == "MISSING_FILE":
                lines.append("        引用 %s -> 实际位于 %s" % (it[1], it[2]))
            else:
                lines.append("        引用 %s" % it[1])

    out = "\n".join(lines)
    print(out)
    if args.report:
        with open(args.report, "w", encoding="utf-8") as fh:
            fh.write(out + "\n")


if __name__ == "__main__":
    main()
