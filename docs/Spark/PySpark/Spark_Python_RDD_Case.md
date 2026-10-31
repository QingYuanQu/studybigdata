---
title: PySpark RDD综合案例
date: 2023-01-14 15:55:26
categories:
- PySpark
---

# RDD 综合案例

## 基于物品的协同过滤

```python
import os
from pyspark import SparkContext, SparkConf
import pandas as pd
from scipy import stats

file_path = ""


def set_spark_context(env):
    global file_path
    sparkConf = SparkConf()
    sparkConf.setAppName("movie_recommend")

    if env == 'local':
        os.environ["HADOOP_HOME"] = "D:\green-soft\hadoop-2.7.3"
        os.environ["SPARK_HOME"] = "D:\green-soft\spark-2.4.8-bin-hadoop2.7"
        file_path = r"file:///C:\Users\Qingyuan_Qu\PycharmProjects\pythonProject\data\\"
        sparkConf.setMaster("local")

    elif env == 'local_python_remote_spark':
        os.environ["HADOOP_HOME"] = "D:\green-soft\hadoop-2.7.3"
        os.environ["HADOOP_CONF_DIR"] = "D:\green-soft\etc\hadoop"
        os.environ["YARN_CONF_DIR"] = "D:\green-soft\etc\hadoop"
        sparkConf.setMaster("yarn")
        sparkConf.set("spark.submit.deployMode", "client")
        sparkConf.set("spark.eventLog.enabled", "true")
        sparkConf.set("spark.eventLog.dir", "hdfs://node0:9000/shared/spark-logs")
        sparkConf.set("spark.yarn.archive", "hdfs://node0:9000/shared/spark-archive")

    elif env == 'yarn':
        sparkConf.set("spark.ui.showConsoleProgress", "true")
        # 使用服务器Python
        os.environ["HADOOP_CONF_DIR"] = "/opt/bigdata/hadoop/default/etc/hadoop"
        os.environ["YARN_CONF_DIR"] = "/opt/bigdata/hadoop/default/etc/hadoop"
        file_path = "hdfs://node0:9000/data/"
        sparkConf.setMaster("yarn")
        sparkConf.set("spark.submit.deployMode", "client")
        sparkConf.set("spark.eventLog.enabled", "true")
        sparkConf.set("spark.eventLog.dir", "hdfs://node0:9000/shared/spark-logs")
        sparkConf.set("spark.yarn.archive", "hdfs://node0:9000/shared/spark-archive")

    sc = SparkContext(conf=sparkConf)
    sc.setLogLevel("INFO")
    return sc


def sim(ur_ur):
    u_r_1 = pd.DataFrame(ur_ur[1][0], columns=['user', 'rating_a'])
    u_r_2 = pd.DataFrame(ur_ur[1][1], columns=['user', 'rating_b'])
    u_r_1.set_index('user', inplace=True)
    u_r_2.set_index('user', inplace=True)
    u_r_r = u_r_1.join(u_r_2, how='inner')
    print(u_r_r)
    pearson_value, P_value = stats.pearsonr(u_r_r['rating_a'].astype(float), u_r_r['rating_b'].astype(float))
    print(ur_ur[0], pearson_value)
    return [ur_ur[0], pearson_value]


def recommend(bc, m_sim):
    bc_df = pd.DataFrame(bc.value, columns=['movie', 'value'])
    bc_df.set_index('movie', inplace=True)

    m_sim_df = pd.DataFrame(m_sim, columns=['movie', 'value'])
    m_sim_df.set_index('movie', inplace=True)
    m_sim_sub_df = m_sim_df.loc[bc_df.index.values]

    print(m_sim_sub_df)

    # 评分，（矩阵相乘）
    score = m_sim_sub_df.T.astype(float).dot(bc_df.astype(float))
    print("dot: \n ", score)
    return score.loc['value']['value']


if __name__ == '__main__':
    '''
    《数据挖掘与机器学习》122页，基于物品的协同过滤
    '''
    env = 'local'
    sc = set_spark_context(env)
    raw_umr_rdd = sc.textFile(file_path + "movies.csv")   # 'A	老炮儿	3.5'
    u_m_r_rdd = raw_umr_rdd.map(lambda line: line.split("\t")[:3]) # ['A', '老炮儿', '3.5']
    m_ur_rdd = u_m_r_rdd.map(lambda line: (line[1], [line[0], line[2]]))
    m_urs_rdd = m_ur_rdd.groupByKey().mapValues(list)
    m_urs_cartesian_rdd = m_urs_rdd.cartesian(m_urs_rdd)
    m_urs_cartesian_unique_rdd = m_urs_cartesian_rdd.filter(lambda m_urs: m_urs[0][0] != m_urs[1][0])

    m__m_rrs_rdd = m_urs_cartesian_unique_rdd.map(
        lambda m_urs_2: (m_urs_2[0][0], (m_urs_2[1][0], [m_urs_2[0][1], m_urs_2[1][1]])))
    m__m_sim_rdd = m__m_rrs_rdd.mapValues(sim)
    m__m_sim_s_rdd = m__m_sim_rdd.groupByKey().mapValues(list)

    # 用户已看过的电影
    u_mr_rdd = u_m_r_rdd.map(lambda line: (line[0], [line[1], line[2]]))
    u_mrs_rdd = u_mr_rdd.groupByKey().mapValues(list)  # (u, [ [m,r],[m,r],[m,r]] )

    m_r_d = u_mrs_rdd.filter(lambda x: x[0] == 'A').values()  # [ [m,r],[m,r] ]
    m_r_d_rdd = sc.parallelize(m_r_d.first())
    bc = sc.broadcast(m_r_d.first())
    sub_sim_rdd = m__m_sim_s_rdd.subtractByKey(m_r_d_rdd)  # (m,[[m,s],[m,s]])
    m_score_rdd = sub_sim_rdd.mapValues(lambda x: recommend(bc, x))
    m_score_sorted_rdd = m_score_rdd.sortBy(lambda x: x[1], False)
    print(m_score_sorted_rdd.collect())
    print(m_score_sorted_rdd.take(3))

```



