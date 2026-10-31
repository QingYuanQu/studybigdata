```python
cd d:\studybigdata\source\_posts; 
python d:\studybigdata\source\_posts\tools\make_ppt.py Hadoop\00-Hadoop_Overview_Architecture.md
python d:\studybigdata\source\_posts\tools\make_ppt.py Hadoop\02-Hadoop_Environment_Setup_SingleNode.md
python d:\studybigdata\source\_posts\tools\make_ppt.py Hadoop\03-Hadoop_Environment_Setup_Distributed_Pseudo.md
python d:\studybigdata\source\_posts\tools\make_ppt.py Hadoop\04-Hadoop_Environment_Setup_Distributed_Fully.md
python d:\studybigdata\source\_posts\tools\make_ppt.py Hadoop\05-Hadoop_Environment_Setup_Hadoop_HA.md
python d:\studybigdata\source\_posts\tools\make_ppt.py Hadoop\03-SSH_免密登录.md
python d:\studybigdata\source\_posts\tools\make_ppt.py DataWareHouse\04-维度建模理论\SQL引擎.md
python d:\studybigdata\source\_posts\tools\make_ppt.py Hive\Hive.md


# 1) 先预览默认范围（只删 export/ 目录），不删任何东西
python d:\studybigdata\source\_posts\tools\clean_ppt_artifacts.py --dry-run

# 2) 确认无误后真实清理（会交互问 y/N）
python d:\studybigdata\source\_posts\tools\clean_ppt_artifacts.py

# 3) 想把散落在各目录、由笔记导出的 pdf 也清掉
python d:\studybigdata\source\_posts\tools\clean_ppt_artifacts.py --loose --dry-run
python d:\studybigdata\source\_posts\tools\clean_ppt_artifacts.py --loose


```
