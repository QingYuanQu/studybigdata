```
pip install freegames -i https://pypi.org/simple
python -m freegames.snake      # 贪吃蛇
```



 `sys.path` 

---

## 🎯 方法一：一行命令（最常用）

```bash
python -c "import sys; print(sys.path)"
```

**输出示例**（Windows）：
```python
['D:\\ProgramData\\anaconda3\\python310.zip', 
 'D:\\ProgramData\\anaconda3\\DLLs', 
 'D:\\ProgramData\\anaconda3\\lib', 
 'D:\\ProgramData\\anaconda3', 
 'D:\\ProgramData\\anaconda3\\lib\\site-packages', 
 ...]
```

---

## 📋 方法二：多行格式化（更易读）

```bash
python -c "import sys; [print(p) for p in sys.path]"
```

输出：
```
D:\ProgramData\anaconda3\python310.zip
D:\ProgramData\anaconda3\DLLs
D:\ProgramData\anaconda3\lib
D:\ProgramData\anaconda3
D:\ProgramData\anaconda3\lib\site-packages
...
```

---

## 🔍 方法三：交互式环境（适合教学演示）

```bash
# 进入 Python 交互式环境
python

# 然后输入：
import sys
print(sys.path)

# 或者更美观的：
import pprint
pprint.pprint(sys.path)
```

---

## 📄 方法四：写一个脚本文件（可复用）

创建 `show_path.py`：
```python
import sys
import pprint

print("=" * 50)
print("Python 模块搜索路径 (sys.path):")
print("=" * 50)
for i, path in enumerate(sys.path, 1):
    print(f"{i:2}. {path}")
print("=" * 50)
print(f"共 {len(sys.path)} 个路径")
```

运行：
```bash
python show_path.py
```

---

## 🎨 炫酷版：带颜色和统计（教学装逼用）

```bash
python -c "import sys; print('\n'.join([f'📁 {p}' for p in sys.path])); print(f'\n✅ 共 {len(sys.path)} 个搜索路径')"
```

输出带 emoji 的版本：
```
📁 D:\ProgramData\anaconda3\python310.zip
📁 D:\ProgramData\anaconda3\DLLs
📁 D:\ProgramData\anaconda3\lib
📁 D:\ProgramData\anaconda3
📁 D:\ProgramData\anaconda3\lib\site-packages

✅ 共 8 个搜索路径
```

---

## 💡 sys.path 包含什么？

| 路径类型          | 示例                          | 说明                   |
| ----------------- | ----------------------------- | ---------------------- |
| **当前目录**      | `''` 或 `.`                   | 运行脚本的目录         |
| **标准库**        | `D:\Python\lib`               | Python 自带的标准库    |
| **site-packages** | `D:\Python\lib\site-packages` | pip 安装的第三方包     |
| **PYTHONPATH**    | 自定义目录                    | 环境变量设置的额外路径 |
| **.zip 文件**     | `D:\Python\python310.zip`     | 压缩的 Python 库       |

---

## 🔧 实际操作（你现在就可以试）

在你的 PowerShell 中执行：

```bash
# 最简单的
python -c "import sys; print(sys.path)"

# 如果你想看自己添加的路径
python -c "import sys; import pprint; pprint.pprint(sys.path)"
```

---

## 📚 教学关联

结合你之前的课程，可以这样解释：

> 当你执行 `pip install freegames` 后，`freegames` 文件夹被安装到了 `site-packages` 目录。而 `python -m freegames.snake` 之所以能找到这个模块，就是因为 **`sys.path` 包含了 `site-packages` 路径**！

验证一下：
```bash
# 查看 site-packages 是否在 sys.path 中
python -c "import sys; print(any('site-packages' in p for p in sys.path))"
```

返回 `True` 就表示路径正确。

---

## ⚡ 快速记忆

- `print(sys.path)` = 告诉 Python "**你去哪里找模块？**"
- 类似 Windows 的 `PATH` 环境变量，但专门用于 Python 模块
- 顺序很重要：**从前往后**查找，找到第一个就停止

---

试试看，告诉我你看到了什么路径！如果有其他疑问，继续问 😊