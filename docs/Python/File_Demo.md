---
title: Python文件操作案例
date: 2023-10-28 14:14:00
categories:
- Python
tags:
- Python
---

# 文件操作练习

#### 背景

当前`4-3`目录中存放了一个Markdown文档和存放相关图片的`pic`目录，目录结构如下：

```shell
4-3:
│-实验手册_5090_1656_18231.md
│
└─pic
        1698495425238.png
        a.png
        clip_image004.png
        clip_image006.png
        c.jpg
        clip_image010.png
        sdfs.png
```

#### 需求

可以看到markdown 文档中插入了较多的图片，图片名字命名不规范，需要根据图片在文档中出现的先后顺序对pic目录中的图片进行重命名。

#### 代码

具体代码如下：

```python
import os
import re

rootdir = os.chdir(f"D:\数据预处理\最终版\最终版-图片名称修正")
os.chdir("4-3") # Markdown所在目录
chapter_name = "chapter4-3"
pic_index = 1

files = os.listdir(".")

pattern = re.compile(r'(\[).*?(\])')


for file in files:
    if file.endswith("md"):
        print(file)
        print(os.getcwd())
        
        new_lines = []
        with open(file,mode="r", encoding="utf-8") as md_file:
            
            lines = md_file.readlines()
            for line in lines:

                match_result = pattern.search(line)
                if match_result != None:
                    old_pic_name = match_result.group(0).removeprefix("[").removesuffix(']')
                    print(old_pic_name)                    
                    try:
                        pic_suffix_index = old_pic_name.index(".")          # pic suffix
                        pic_suffix_name = old_pic_name[pic_suffix_index:]
                        new_pic_name = chapter_name+"-"+str(pic_index)+ pic_suffix_name # 新图片名： chapter + index + suffix
                        line = line.replace(old_pic_name, new_pic_name)
                        new_lines.append(line)
                        os.rename("pic//"+old_pic_name, "pic//"+new_pic_name) # 重命名图片

                        pic_index +=1
                    except:
                        print(old_pic_name)
                else:
                    new_lines.append(line)
        
        with open(file,mode="w", encoding="utf-8") as md_file:
            md_file.writelines(new_lines)

```

