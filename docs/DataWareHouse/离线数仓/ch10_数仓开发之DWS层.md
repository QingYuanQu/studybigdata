# 第10章 数仓开发之DWS层

设计要点：

（1）DWS层的设计参考指标体系

（2）DWS层的数据存储格式为orc列式存储+snappy压缩。

（3）DWS层表名的命名规范为dws_数据域_统计粒度_业务过程_统计周期（1d/nd/td）

注：1d标识最近1日，nd表示最近n日，td表示历史至今。

## 10.1 最近1日汇总表

### 10.1.1 交易域用户粒度用户加购最近 1 日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_user_cart_add_1d;
CREATE EXTERNAL TABLE dws_trade_user_cart_add_1d
(
    `user_id`      STRING COMMENT '用户id',
    `course_count` BIGINT COMMENT '加购课程数'
) COMMENT '交易域用户粒度用户加购最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_user_cart_add_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table edu.dws_trade_user_cart_add_1d
	partition(dt)
select user_id,
       count(course_id) course_count,
       dt
from edu.dwd_trade_cart_add_inc
group by user_id, dt;
```

（2）每日装载

``` text
insert overwrite table edu.dws_trade_user_cart_add_1d
    partition (dt = '2022-02-22')
select user_id,
       count(course_id) course_count
from edu.dwd_trade_cart_add_inc
where dt = '2022-02-22'
group by user_id;
```

### 10.1.2 交易域用户粒度用户支付最近1日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_user_payment_1d;
CREATE EXTERNAL TABLE dws_trade_user_payment_1d
(
    `user_id`       STRING COMMENT '用户id',
    `payment_count` BIGINT COMMENT '支付次数'
) COMMENT '交易域用户粒度用户支付最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_user_payment_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table edu.dws_trade_user_payment_1d
partition (dt)
select user_id,
       count(distinct order_id) payment_count,
       dt
from edu.dwd_trade_pay_detail_suc_inc
group by user_id, dt;
```

（2）每日装载

``` text
insert overwrite table edu.dws_trade_user_payment_1d
    partition (dt = '2022-02-22')
select user_id,
       count(distinct order_id) payment_count
from edu.dwd_trade_pay_detail_suc_inc
where dt = '2022-02-22'
group by user_id;
```

### 10.1.3 交易域会话粒度用户下单最近1日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_session_order_1d;
CREATE EXTERNAL TABLE dws_trade_session_order_1d
(
    `session_id`   STRING COMMENT '会话id',
    `user_id`      STRING COMMENT '用户id',
    `province_id`  STRING COMMENT '省份id',
    `source_id`    STRING COMMENT '引流来源id',
    `source_site`  STRING COMMENT '引流名称',
    `order_count`  BIGINT COMMENT '下单次数',
    `order_amount` DECIMAL(16, 2) COMMENT '下单金额'
) COMMENT '交易域会话粒度用户下单最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_session_order_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table  edu.dws_trade_session_order_1d
partition (dt)
select session_id,
       user_id,
       province_id,
       source_id,
       source_site,
       order_count,
       order_amount,
       dt
from (
         select session_id,
                user_id,
                province_id,
                source_id,
                count(distinct order_id) order_count,
                sum(final_amount)        order_amount,
                dt
         from  edu.dwd_trade_order_detail_inc
         group by session_id, user_id, province_id, source_id, dt
     ) ag_t
         left join
     (
         select id,
                source_site
         from edu.dim_source_full
         where dt = '2022-02-21'
     ) d_source
     on ag_t.source_id = d_source.id;
```

（2）每日装载

``` text
insert overwrite table  edu.dws_trade_session_order_1d
    partition (dt = '2022-02-22')
select session_id,
       user_id,
       province_id,
       source_id,
       source_site,
       order_count,
       order_amount
from (select session_id,
             user_id,
             province_id,
             source_id,
             count(distinct order_id) order_count,
             sum(final_amount)        order_amount
      from  edu.dwd_trade_order_detail_inc
      where dt = '2022-02-22'
      group by session_id, user_id, province_id, source_id) ag_t
         left join
     (select id,
             source_site
      from edu.dim_source_full
      where dt = '2022-02-22'
     ) d_source
     on ag_t.source_id = d_source.id;
```

### 10.1.4 考试域试卷粒度考试最近1日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_examination_paper_exam_1d;
CREATE EXTERNAL TABLE dws_examination_paper_exam_1d
(
    `paper_id`         STRING COMMENT '试卷id',
    `paper_title`      STRING COMMENT '试卷标题',
    `course_id`        STRING COMMENT '课程id',
    `course_name`      STRING COMMENT '课程名称',
    `subject_id`       STRING COMMENT '学科id',
    `subject_name`     STRING COMMENT '学科名称',
    `category_id`      STRING COMMENT '分类id',
    `category_name`    STRING COMMENT '分类名称',
    `avg_score`        DECIMAL(16, 2) COMMENT '平均分',
    `avg_during_sec`   BIGINT COMMENT '平均时长',
    `total_score`      BIGINT COMMENT '总分',
    `total_during_sec` BIGINT COMMENT '总时长',
    `user_count`       BIGINT COMMENT '用户数'
) COMMENT '考试域试卷粒度考试最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_examination_paper_exam_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table edu.dws_examination_paper_exam_1d
    partition (dt)
select paper_id,
       paper_title,
       course_id,
       course_name,
       subject_id,
       subject_name,
       category_id,
       category_name,
       avg_score,
       avg_during_sec,
       total_score,
       total_during_sec,
       user_count,
       dt
from (select paper_id,
             avg(score)        avg_score,
             avg(duration_sec) avg_during_sec,
             sum(score)        total_score,
             sum(duration_sec) total_during_sec,
             count(user_id)    user_count,
             dt
      from edu.dwd_examination_test_paper_inc
      group by paper_id, dt) ex
         left join
     (select id,
             paper_title,
             course_id
      from edu.dim_paper_full
      where dt = '2022-02-21') paper
     on ex.paper_id = paper.id
         left join
     (select id,
             course_name,
             subject_id,
             subject_name,
             category_id,
             category_name
      from edu.dim_course_full
      where dt = '2022-02-21'
     ) dim_course
     on paper.course_id = dim_course.id;
```

（2）每日装载

``` text
insert overwrite table edu.dws_examination_paper_exam_1d
    partition (dt = '2022-02-22')
select paper_id,
       paper_title,
       course_id,
       course_name,
       subject_id,
       subject_name,
       category_id,
       category_name,
       avg_score,
       avg_during_sec,
       total_score,
       total_during_sec,
       user_count
from (select paper_id,
             avg(score)        avg_score,
             avg(duration_sec) avg_during_sec,
             sum(score)        total_score,
             sum(duration_sec) total_during_sec,
             count(user_id)    user_count
      from edu.dwd_examination_test_paper_inc
      where dt = '2022-02-22'
      group by paper_id) exa
         left join
     (select id,
             paper_title,
             course_id
      from edu.dim_paper_full
      where dt = '2022-02-22'
     ) paper
     on exa.paper_id = paper.id
         left join
     (select id,
             course_name,
             subject_id,
             subject_name,
             category_id,
             category_name
      from edu.dim_course_full
      where dt = '2022-02-22'
     ) dim_course
     on paper.course_id = dim_course.id;
```

### 10.1.5 考试域试卷分数段粒度最近1日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_examination_paper_duration_exam_1d;
CREATE EXTERNAL TABLE dws_examination_paper_duration_exam_1d
(
    `paper_id`      STRING COMMENT '试卷id',
    `paper_title`   STRING COMMENT '试卷名称',
    `duration_name` STRING COMMENT '分数区间',
    `user_count`    BIGINT COMMENT '用户数'
) COMMENT '考试域试卷-分数段粒度最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_examination_paper_duration_exam_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table edu.dws_examination_paper_duration_exam_1d
    partition (dt)
select paper_id,
       paper_title,
       duration_name,
       user_count,
       dt
from (select paper_id,
             duration_name,
             count(user_id) user_count,
             dt
      from (select paper_id,
                   case
                       when score >= 0 and score < 60
                           then '[0, 60)'
                       when score >= 60 and score < 70
                           then '[60, 70)'
                       when score >= 70 and score < 80
                           then '[70, 80)'
                       when score >= 80 and score < 90
                           then '[80, 90)'
                       when score >= 90 and score <= 100
                           then '[90, 100]'
                       end duration_name,
                   user_id,
                   dt
            from edu.dwd_examination_test_paper_inc) origin
      group by paper_id, duration_name, dt) dur
         left join
     (select id,
             paper_title
      from edu.dim_paper_full
      where dt = '2022-02-21'
     ) paper
     on dur.paper_id = paper.id;
```

（2）每日装载

``` text
insert overwrite table edu.dws_examination_paper_duration_exam_1d
    partition (dt = '2022-02-22')
select paper_id,
       paper_title,
       duration_name,
       user_count
from (
         select paper_id,
                duration_name,
                count(user_id) user_count
         from (select paper_id,
                      case
                          when score >= 0 and score < 60 then '[0, 60)'
                          when score >= 60 and score < 70 then '[60, 70)'
                          when score >= 70 and score < 80 then '[70, 80)'
                          when score >= 80 and score < 90 then '[80, 90)'
                          when score >= 90 and score <= 100 then '[90, 100]'
                          end duration_name,
                      user_id
               from edu.dwd_examination_test_paper_inc
               where dt = '2022-02-22') orgin
         group by paper_id, duration_name
     ) dur
         left join
     (
         select id,
                paper_title
         from edu.dim_paper_full
         where dt = '2022-02-22'
     ) paper
     on dur.paper_id = paper.id;
```

### 10.1.6 考试域题目粒度考试最近1日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_examination_question_exam_1d;
CREATE EXTERNAL TABLE dws_examination_question_exam_1d
(
    `question_id`   STRING COMMENT '题目id',
    `correct_count` BIGINT COMMENT '正确答题次数',
    `answer_count`  BIGINT COMMENT '答题次数'
) COMMENT '考试域题目粒度考试最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_examination_question_exam_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table edu.dws_examination_question_exam_1d
    partition (dt)
select question_id,
             sum(if(is_correct = 1, 1, 0))          correct_count,
             count(*)                               answer_count,
             date_format(create_time, 'yyyy-MM-dd') dt
      from edu.dwd_examination_test_question_inc
      group by question_id, date_format(create_time, 'yyyy-MM-dd');
```

（2）每日装载

``` text
insert overwrite table edu.dws_examination_question_exam_1d
    partition (dt = '2022-02-22')
select question_id,
             sum(if(is_correct = 1, 1, 0))          correct_count,
             count(*)                               answer_count
      from edu.dwd_examination_test_question_inc
      where dt = '2022-02-22'
      group by question_id;
```

### 10.1.7 流量域会话粒度页面浏览最近1日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_traffic_session_page_view_1d;
CREATE EXTERNAL TABLE dws_traffic_session_page_view_1d
(
    `session_id`  STRING COMMENT '会话id',
    `mid_id`      STRING COMMENT '设备id',
    `user_id`     STRING COMMENT '用户id',
    `source_id`   STRING COMMENT '引流来源id',
    `source_site` STRING COMMENT '引流来源名称',
    `page_count`  BIGINT COMMENT '页面总数',
    `during_time` BIGINT COMMENT '停留时长,单位: 毫秒'
) COMMENT '流量域会话粒度页面浏览最近1日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_traffic_session_page_view_1d/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

``` text
insert overwrite table edu.dws_traffic_session_page_view_1d
  partition(dt = '2022-02-21')
select session_id,
       mid_id,
       user_id,
       source_id,
       source_site,
       page_count,
       during_time
from (
         select session_id,
                max(mid_id)      mid_id,
                max(user_id)     user_id,
                max(source_id)   source_id,
                count(*)         page_count,
                sum(during_time) during_time,
                dt
         from edu.dwd_traffic_page_view_inc
         where dt = '2022-02-21'
         group by session_id, dt
     ) pv
         left join
     (
         select id,
                source_site
         from edu.dim_source_full
         where dt = '2022-02-21'
     ) dim
     on pv.source_id = dim.id;
```

### 10.1.8 数据装载脚本

**1）首日数据装载脚本**

（1）在hadoop102的/home/atguigu/bin目录下创建dwd_to_dws_1d_init.sh

``` bash
[zhangsan@node0 bin]$ vim dwd_to_dws_1d_init.sh
```

（2）编写如下内容

``` text
#!/bin/bash
if [ -n "$2" ] ;then
    do_date=$2
else
    echo "请传入日期参数"
    exit
fi
APP=edu
dws_trade_user_cart_add_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table ${APP}.dws_trade_user_cart_add_1d
	partition(dt)
select user_id,
       count(course_id) course_count,
       dt
from ${APP}.dwd_trade_cart_add_inc
group by user_id, dt;"
dws_trade_user_payment_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table ${APP}.dws_trade_user_payment_1d
partition (dt)
select user_id,
       count(distinct order_id) payment_count,
       dt
from ${APP}.dwd_trade_pay_detail_suc_inc
group by user_id, dt;"
dws_trade_session_order_1d="
insert overwrite table  ${APP}.dws_trade_session_order_1d
partition (dt)
select session_id,
       user_id,
       province_id,
       source_id,
       source_site,
       order_count,
       order_amount,
       dt
from (
         select session_id,
                user_id,
                province_id,
                source_id,
                count(distinct order_id) order_count,
                sum(final_amount)        order_amount,
                dt
         from  ${APP}.dwd_trade_order_detail_inc
         group by session_id, user_id, province_id, source_id, dt
     ) ag_t
         left join
     (
         select id,
                source_site
         from ${APP}.dim_source_full
         where dt = '$do_date'
     ) d_source
     on ag_t.source_id = d_source.id;"
dws_examination_paper_exam_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table ${APP}.dws_examination_paper_exam_1d
    partition (dt)
select paper_id,
       paper_title,
       course_id,
       course_name,
       subject_id,
       subject_name,
       category_id,
       category_name,
       avg_score,
       avg_during_sec,
       total_score,
       total_during_sec,
       user_count,
       dt
from (select paper_id,
             avg(score)        avg_score,
             avg(duration_sec) avg_during_sec,
             sum(score)        total_score,
             sum(duration_sec) total_during_sec,
             count(user_id)    user_count,
             dt
      from ${APP}.dwd_examination_test_paper_inc
      group by paper_id, dt) ex
         left join
     (select id,
             paper_title,
             course_id
      from ${APP}.dim_paper_full
      where dt = '$do_date') paper
     on ex.paper_id = paper.id
         left join
     (select id,
             course_name,
             subject_id,
             subject_name,
             category_id,
             category_name
      from ${APP}.dim_course_full
      where dt = '$do_date'
     ) dim_course
     on paper.course_id = dim_course.id;"
dws_examination_paper_duration_exam_1d="
insert overwrite table ${APP}.dws_examination_paper_duration_exam_1d
    partition (dt)
select paper_id,
       paper_title,
       duration_name,
       user_count,
       dt
from (select paper_id,
             duration_name,
             count(user_id) user_count,
             dt
      from (select paper_id,
                   case
                       when score >= 0 and score < 60
                           then '[0, 60)'
                       when score >= 60 and score < 70
                           then '[60, 70)'
                       when score >= 70 and score < 80
                           then '[70, 80)'
                       when score >= 80 and score < 90
                           then '[80, 90)'
                       when score >= 90 and score <= 100
                           then '[90, 100]'
                       end duration_name,
                   user_id,
                   dt
            from ${APP}.dwd_examination_test_paper_inc) origin
      group by paper_id, duration_name, dt) dur
         left join
     (select id,
             paper_title
      from ${APP}.dim_paper_full
      where dt = '$do_date'
     ) paper
     on dur.paper_id = paper.id;"
dws_examination_question_exam_1d="
insert overwrite table ${APP}.dws_examination_question_exam_1d
    partition (dt)
select question_id,
             sum(if(is_correct = 1, 1, 0))          correct_count,
             count(*)                               answer_count,
             date_format(create_time, 'yyyy-MM-dd') dt
      from ${APP}.dwd_examination_test_question_inc
      group by question_id, date_format(create_time, 'yyyy-MM-dd');"
dws_traffic_session_page_view_1d="
insert overwrite table ${APP}.dws_traffic_session_page_view_1d
  partition(dt = '$do_date')
select session_id,
       mid_id,
       user_id,
       source_id,
       source_site,
       page_count,
       during_time
from (
         select session_id,
                max(mid_id)      mid_id,
                max(user_id)     user_id,
                max(source_id)   source_id,
                count(*)         page_count,
                sum(during_time) during_time,
                dt
         from ${APP}.dwd_traffic_page_view_inc
         where dt = '$do_date'
         group by session_id, dt
     ) pv
         left join
     (
         select id,
                source_site
         from ${APP}.dim_source_full
         where dt = '$do_date'
     ) dim
     on pv.source_id = dim.id;"
case $1 in
    dws_trade_user_cart_add_1d|dws_trade_user_payment_1d|dws_trade_session_order_1d|dws_examination_paper_exam_1d|dws_examination_paper_duration_exam_1d|dws_examination_question_exam_1d|dws_traffic_session_page_view_1d)
        eval "hive -e \"\$$1\""
    ;;
    "all" )
        hive -e "${dws_trade_user_cart_add_1d}${dws_trade_user_payment_1d}${dws_trade_session_order_1d}${dws_examination_paper_exam_1d}${dws_examination_paper_duration_exam_1d}${dws_examination_question_exam_1d}${dws_traffic_session_page_view_1d}"
    ;;
esac
```

（3）增加脚本执行权限

``` bash
[zhangsan@node0 bin]$ chmod +x dwd_to_dws_1d_init.sh
```

（4）脚本用法

``` bash
[zhangsan@node0 bin]$ dwd_to_dws_1d_init.sh all 2022-02-21
```

**2）每日数据装载脚本**

（1）在hadoop102的/home/atguigu/bin目录下创建dwd_to_dws_1d.sh

``` bash
[zhangsan@node0 bin]$ vim dwd_to_dws_1d.sh
```

（2）编写如下内容

``` text
#!/bin/bash
if [ -n "$2" ] ;then
    do_date=$2
else
    do_date=`date -d "-1 day" +%F`
fi
APP=edu
dws_trade_user_cart_add_1d="
insert overwrite table ${APP}.dws_trade_user_cart_add_1d
    partition (dt = '$do_date')
select user_id,
       count(course_id) course_count
from ${APP}.dwd_trade_cart_add_inc
where dt = '$do_date'
group by user_id;"
dws_trade_user_payment_1d="
insert overwrite table ${APP}.dws_trade_user_payment_1d
    partition (dt = '$do_date')
select user_id,
       count(distinct order_id) payment_count
from ${APP}.dwd_trade_pay_detail_suc_inc
where dt = '$do_date'
group by user_id;"
dws_trade_session_order_1d="
insert overwrite table  ${APP}.dws_trade_session_order_1d
    partition (dt = '$do_date')
select session_id,
       user_id,
       province_id,
       source_id,
       source_site,
       order_count,
       order_amount
from (select session_id,
             user_id,
             province_id,
             source_id,
             count(distinct order_id) order_count,
             sum(final_amount)        order_amount
      from  ${APP}.dwd_trade_order_detail_inc
      where dt = '$do_date'
      group by session_id, user_id, province_id, source_id) ag_t
         left join
     (select id,
             source_site
      from ${APP}.dim_source_full
      where dt = '$do_date'
     ) d_source
     on ag_t.source_id = d_source.id;"
dws_examination_paper_exam_1d="
insert overwrite table ${APP}.dws_examination_paper_exam_1d
    partition (dt = '$do_date')
select paper_id,
       paper_title,
       course_id,
       course_name,
       subject_id,
       subject_name,
       category_id,
       category_name,
       avg_score,
       avg_during_sec,
       total_score,
       total_during_sec,
       user_count
from (select paper_id,
             avg(score)        avg_score,
             avg(duration_sec) avg_during_sec,
             sum(score)        total_score,
             sum(duration_sec) total_during_sec,
             count(user_id)    user_count
      from ${APP}.dwd_examination_test_paper_inc
      where dt = '$do_date'
      group by paper_id) exa
         left join
     (select id,
             paper_title,
             course_id
      from ${APP}.dim_paper_full
      where dt = '$do_date'
     ) paper
     on exa.paper_id = paper.id
         left join
     (select id,
             course_name,
             subject_id,
             subject_name,
             category_id,
             category_name
      from ${APP}.dim_course_full
      where dt = '$do_date'
     ) dim_course
     on paper.course_id = dim_course.id;"
dws_examination_paper_duration_exam_1d="
insert overwrite table ${APP}.dws_examination_paper_duration_exam_1d
    partition (dt = '$do_date')
select paper_id,
       paper_title,
       duration_name,
       user_count
from (
         select paper_id,
                duration_name,
                count(user_id) user_count
         from (select paper_id,
                      case
                          when score >= 0 and score < 60 then '[0, 60)'
                          when score >= 60 and score < 70 then '[60, 70)'
                          when score >= 70 and score < 80 then '[70, 80)'
                          when score >= 80 and score < 90 then '[80, 90)'
                          when score >= 90 and score <= 100 then '[90, 100]'
                          end duration_name,
                      user_id
               from ${APP}.dwd_examination_test_paper_inc
               where dt = '$do_date') orgin
         group by paper_id, duration_name
     ) dur
         left join
     (
         select id,
                paper_title
         from ${APP}.dim_paper_full
         where dt = '$do_date'
     ) paper
     on dur.paper_id = paper.id;"
dws_examination_question_exam_1d="
insert overwrite table ${APP}.dws_examination_question_exam_1d
    partition (dt = '$do_date')
select question_id,
             sum(if(is_correct = 1, 1, 0))          correct_count,
             count(*)                               answer_count
      from ${APP}.dwd_examination_test_question_inc
      where dt = '$do_date'
      group by question_id;"
dws_traffic_session_page_view_1d="
insert overwrite table ${APP}.dws_traffic_session_page_view_1d
  partition(dt = '$do_date')
select session_id,
       mid_id,
       user_id,
       source_id,
       source_site,
       page_count,
       during_time
from (
         select session_id,
                max(mid_id)      mid_id,
                max(user_id)     user_id,
                max(source_id)   source_id,
                count(*)         page_count,
                sum(during_time) during_time,
                dt
         from ${APP}.dwd_traffic_page_view_inc
         where dt = '$do_date'
         group by session_id, dt
     ) pv
         left join
     (
         select id,
                source_site
         from ${APP}.dim_source_full
         where dt = '$do_date'
     ) dim
     on pv.source_id = dim.id;"
case $1 in
    dws_trade_user_cart_add_1d|dws_trade_user_payment_1d|dws_trade_session_order_1d|dws_examination_paper_exam_1d|dws_examination_paper_duration_exam_1d|dws_examination_question_exam_1d|dws_traffic_session_page_view_1d)
        eval "hive -e \"\$$1\""
    ;;
    "all" )
        hive -e "${dws_trade_user_cart_add_1d}${dws_trade_user_payment_1d}${dws_trade_session_order_1d}${dws_examination_paper_exam_1d}${dws_examination_paper_duration_exam_1d}${dws_examination_question_exam_1d}${dws_traffic_session_page_view_1d}"
    ;;
esac
```

（3）增加脚本执行权限

``` bash
[zhangsan@node0 bin]$ chmod +x dwd_to_dws_1d.sh
```

（4）脚本用法

``` bash
[zhangsan@node0 bin]$ dwd_to_dws_1d.sh all 2022-02-22
```

## 10.2 最近n日汇总表

### 10.2.1 交易域用户粒度用户加购最近n日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_user_cart_add_nd;
CREATE EXTERNAL TABLE dws_trade_user_cart_add_nd
(
    `user_id`          STRING COMMENT '用户id',
    `course_count_7d`  BIGINT COMMENT '最近7日加购课程数',
    `course_count_30d` BIGINT COMMENT '最近30日加购课程数'
) COMMENT '交易域用户粒度用户加购最近n日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_user_cart_add_nd/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

``` text
insert overwrite table edu.dws_trade_user_cart_add_nd
    partition (dt = '2022-02-21')
select user_id,
       sum(if(dt >= date_add('2022-02-21', -6), course_count, 0)) course_count_7d,
       sum(course_count)                                          course_count_30d
from edu.dws_trade_user_cart_add_1d
where dt >= date_add('2022-02-21', -29)
  and dt <= '2022-02-21'
group by user_id;
```

### 10.2.2 交易域用户粒度用户支付最近n日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_user_payment_nd;
CREATE EXTERNAL TABLE dws_trade_user_payment_nd
(
    `user_id`           STRING COMMENT '用户id',
    `payment_count_7d`  BIGINT COMMENT '最近7日支付次数',
    `payment_count_30d` BIGINT COMMENT '最近30日支付次数'
) COMMENT '交易域用户粒度用户支付最近n日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_user_payment_nd/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

``` text
insert overwrite table edu.dws_trade_user_payment_nd
    partition (dt = '2022-02-21')
select user_id,
       sum(if(dt >= date_add('2022-02-21', -6), payment_count, 0)) payment_count_7d,
       sum(payment_count)                                          payment_count_30d
from edu.dws_trade_user_payment_1d
where dt >= date_add('2022-02-21', -29)
  and dt <= '2022-02-21'
group by user_id;
```

### 10.2.3 考试域试卷粒度考试最近n日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_examination_paper_exam_nd;
CREATE EXTERNAL TABLE dws_examination_paper_exam_nd
(
    `paper_id`             STRING COMMENT '试卷id',
    `paper_title`          STRING COMMENT '试卷标题',
    `course_id`            STRING COMMENT '课程id',
    `course_name`          STRING COMMENT '课程名称',
    `subject_id`           STRING COMMENT '学科id',
    `subject_name`         STRING COMMENT '学科名称',
    `category_id`          STRING COMMENT '分类id',
    `category_name`        STRING COMMENT '分类名称',
    `avg_score_7d`         DECIMAL(16, 2) COMMENT '最近7日平均分',
    `avg_during_sec_7d`    BIGINT COMMENT '最近7日平均时长',
    `total_score_7d`       BIGINT COMMENT '最近7日总分',
    `total_during_sec_7d`  BIGINT COMMENT '最近7日总时长',
    `user_count_7d`        BIGINT COMMENT '最近7日用户数',
    `avg_score_30d`        DECIMAL(16, 2) COMMENT '最近30日平均分',
    `avg_during_sec_30d`   BIGINT COMMENT '最近30日平均时长',
    `total_score_30d`      BIGINT COMMENT '最近30日总分',
    `total_during_sec_30d` BIGINT COMMENT '最近30日总时长',
    `user_count_30d`       BIGINT COMMENT '最近30日用户数'
) COMMENT '考试域试卷粒度考试最近n日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_examination_paper_exam_nd/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

``` text
insert overwrite table edu.dws_examination_paper_exam_nd
    partition (dt = '2022-02-21')
select paper_id,
       paper_title,
       course_id,
       course_name,
       subject_id,
       subject_name,
       category_id,
       category_name,
       sum(if(dt >= date_add('2022-02-21', -6), total_score, 0)) /
       sum(if(dt >= date_add('2022-02-21', -6), user_count, 0))       avg_score_7d,
       sum(if(dt >= date_add('2022-02-21', -6), total_during_sec, 0)) /
       sum(if(dt >= date_add('2022-02-21', -6), user_count, 0))       avg_during_sec_7d,
       sum(if(dt >= date_add('2022-02-21', -6), total_score, 0))      total_score_7d,
       sum(if(dt >= date_add('2022-02-21', -6), total_during_sec, 0)) total_during_sec_7d,
       sum(if(dt >= date_add('2022-02-21', -6), user_count, 0))       user_count_7d,
       sum(total_score) / sum(user_count)                             avg_score_30d,
       sum(total_during_sec) / sum(user_count)                        avg_during_sec_30d,
       sum(total_score)                                               total_score_30d,
       sum(total_during_sec)                                          total_during_sec_30d,
       sum(user_count)                                                user_count_30d
from edu.dws_examination_paper_exam_1d
where dt >= date_add('2022-02-21', -29)
  and dt <= '2022-02-21'
group by paper_id,
         paper_title,
         course_id,
         course_name,
         subject_id,
         subject_name,
         category_id,
         category_name;
```

### 10.2.4 考试域试卷分数段粒度最近n日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_examination_paper_duration_exam_nd;
CREATE EXTERNAL TABLE dws_examination_paper_duration_exam_nd
(
    `paper_id`       STRING COMMENT '试卷id',
    `paper_title`    STRING COMMENT '试卷名称',
    `duration_name`  STRING COMMENT '分数区间',
    `user_count_7d`  BIGINT COMMENT '最近7日用户数',
    `user_count_30d` BIGINT COMMENT '最近30日用户数'
) COMMENT '考试域试卷-分数段粒度最近n日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_examination_paper_duration_exam_nd/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

``` text
insert overwrite table edu.dws_examination_paper_duration_exam_nd
    partition (dt = '2022-02-21')
select paper_id,
       paper_title,
       duration_name,
       sum(if(dt >= date_add('2022-02-21', -6), user_count, 0)) user_count_7d,
       sum(user_count)                                          user_count_30d
from edu.dws_examination_paper_duration_exam_1d
where dt >= date_add('2022-02-21', -29)
  and dt <= '2022-02-21'
group by paper_id,
         paper_title,
         duration_name;
```

### 10.2.5 考试域题目粒度考试最近n日汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_examination_question_exam_nd;
CREATE EXTERNAL TABLE dws_examination_question_exam_nd
(
    `question_id`       STRING COMMENT '题目id',
    `correct_count_7d`  BIGINT COMMENT '最近7日正确答题次数',
    `answer_count_7d`   BIGINT COMMENT '最近7日答题次数',
    `correct_count_30d` BIGINT COMMENT '最近30日正确答题次数',
    `answer_count_30d`  BIGINT COMMENT '最近30日答题次数'
) COMMENT '考试域题目粒度考试最近n日汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_examination_question_exam_nd/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

``` text
insert overwrite table edu.dws_examination_question_exam_nd
    partition (dt = '2022-02-21')
select question_id,
       sum(if(dt >= date_add('2022-02-21', -6), correct_count, 0)) correct_count_7d,
       sum(if(dt >= date_add('2022-02-21', -6), answer_count, 0))  answer_count_7d,
       sum(correct_count)                                          correct_count_30d,
       sum(answer_count)                                           answer_count_30d
from edu.dws_examination_question_exam_1d
where dt >= date_add('2022-02-21', -29)
  and dt <= '2022-02-21'
group by question_id;
```

### 10.2.6 数据装载脚本

**1）每日数据装载脚本**

（1）在hadoop102的/home/atguigu/bin目录下创建dws_1d_to_dws_nd.sh

``` bash
[zhangsan@node0 bin]$ vim dws_1d_to_dws_nd.sh
```

（2）编写如下内容

``` text
#!/bin/bash
if [ -n "$2" ] ;then
    do_date=$2
else
    do_date=`date -d "-1 day" +%F`
fi
APP=edu
dws_trade_user_cart_add_nd="
insert overwrite table ${APP}.dws_trade_user_cart_add_nd
    partition (dt = '$do_date')
select user_id,
       sum(if(dt >= date_add('$do_date', -6), course_count, 0)) course_count_7d,
       sum(course_count)                                          course_count_30d
from ${APP}.dws_trade_user_cart_add_1d
where dt >= date_add('$do_date', -29)
  and dt <= '$do_date'
group by user_id;"
dws_trade_user_payment_nd="
insert overwrite table ${APP}.dws_trade_user_payment_nd
    partition (dt = '$do_date')
select user_id,
       sum(if(dt >= date_add('$do_date', -6), payment_count, 0)) payment_count_7d,
       sum(payment_count)                                          payment_count_30d
from ${APP}.dws_trade_user_payment_1d
where dt >= date_add('$do_date', -29)
  and dt <= '$do_date'
group by user_id;"
dws_examination_paper_exam_nd="
insert overwrite table ${APP}.dws_examination_paper_exam_nd
    partition (dt = '$do_date')
select paper_id,
       paper_title,
       course_id,
       course_name,
       subject_id,
       subject_name,
       category_id,
       category_name,
       sum(if(dt >= date_add('$do_date', -6), total_score, 0)) /
       sum(if(dt >= date_add('$do_date', -6), user_count, 0))       avg_score_7d,
       sum(if(dt >= date_add('$do_date', -6), total_during_sec, 0)) /
       sum(if(dt >= date_add('$do_date', -6), user_count, 0))       avg_during_sec_7d,
       sum(if(dt >= date_add('$do_date', -6), total_score, 0))      total_score_7d,
       sum(if(dt >= date_add('$do_date', -6), total_during_sec, 0)) total_during_sec_7d,
       sum(if(dt >= date_add('$do_date', -6), user_count, 0))       user_count_7d,
       sum(total_score) / sum(user_count)                             avg_score_30d,
       sum(total_during_sec) / sum(user_count)                        avg_during_sec_30d,
       sum(total_score)                                               total_score_30d,
       sum(total_during_sec)                                          total_during_sec_30d,
       sum(user_count)                                                user_count_30d
from ${APP}.dws_examination_paper_exam_1d
where dt >= date_add('$do_date', -29)
  and dt <= '$do_date'
group by paper_id,
         paper_title,
         course_id,
         course_name,
         subject_id,
         subject_name,
         category_id,
         category_name;"
dws_examination_paper_duration_exam_nd="
insert overwrite table ${APP}.dws_examination_paper_duration_exam_nd
    partition (dt = '$do_date')
select paper_id,
       paper_title,
       duration_name,
       sum(if(dt >= date_add('$do_date', -6), user_count, 0)) user_count_7d,
       sum(user_count)                                          user_count_30d
from ${APP}.dws_examination_paper_duration_exam_1d
where dt >= date_add('$do_date', -29)
  and dt <= '$do_date'
group by paper_id,
         paper_title,
         duration_name;"
dws_examination_question_exam_nd="
insert overwrite table ${APP}.dws_examination_question_exam_nd
    partition (dt = '$do_date')
select question_id,
       sum(if(dt >= date_add('$do_date', -6), correct_count, 0)) correct_count_7d,
       sum(if(dt >= date_add('$do_date', -6), answer_count, 0))  answer_count_7d,
       sum(correct_count)                                          correct_count_30d,
       sum(answer_count)                                           answer_count_30d
from ${APP}.dws_examination_question_exam_1d
where dt >= date_add('$do_date', -29)
  and dt <= '$do_date'
group by question_id;"
case $1 in
    dws_trade_user_cart_add_nd|dws_trade_user_payment_nd|dws_examination_paper_exam_nd|dws_examination_paper_duration_exam_nd|dws_examination_question_exam_nd)
        eval "hive -e \"\$$1\""
    ;;
    "all" )
        hive -e "${dws_trade_user_cart_add_nd}${dws_trade_user_payment_nd}${dws_examination_paper_exam_nd}${dws_examination_paper_duration_exam_nd}${dws_examination_question_exam_nd}"
    ;;
esac
```

（3）增加脚本执行权限

``` bash
[zhangsan@node0 bin]$ chmod +x dws_1d_to_dws_nd.sh
```

（4）脚本用法

``` bash
[zhangsan@node0 bin]$ dws_1d_to_dws_nd.sh all 2022-02-21
```

## 10.3 历史至今汇总表

### 10.3.1 交易域用户粒度下单历史至今汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_user_order_td;
CREATE EXTERNAL TABLE dws_trade_user_order_td
(
    `user_id`        STRING COMMENT '用户id',
    `order_dt_first` STRING COMMENT '首次下单日期',
    `order_dt_last`  STRING COMMENT '末次下单日期'
) COMMENT '交易域用户粒度用户下单历史至今汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_user_order_td/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
insert overwrite table edu.dws_trade_user_order_td
    partition (dt = '2022-02-21')
select user_id,
       min(create_time) order_dt_first,
       max(create_time) order_dt_last
from edu.dwd_trade_order_detail_inc
group by user_id;
```

（2）每日装载

``` text
insert overwrite table dws_trade_user_order_td partition (dt='2022-02-22')
select  nvl(old.user_id,nod.user_id) user_id,
        `if`(old.order_dt_first is null,nod.create_time,old.order_dt_first) order_dt_first,
        `if`(nod.create_time is null,old.order_dt_last,nod.create_time) order_dt_last
from (
     select user_id,
            max(create_time) create_time
    from dwd_trade_order_detail_inc
    where dt='2022-02-22'
    group by user_id
)nod
full outer join (
    select user_id,
           order_dt_first,
           order_dt_last
    from dws_trade_user_order_td
    where dt=date_sub('2022-02-22',1)
)old
on nod.user_id=old.user_id;
```

### 10.3.2 交易域用户粒度用户支付历史至今汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_trade_user_payment_td;
CREATE EXTERNAL TABLE dws_trade_user_payment_td
(
    `user_id`          STRING COMMENT '用户id',
    `payment_dt_first` STRING COMMENT '首次支付日期'
) COMMENT '交易域用户粒度用户支付历史至今汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_trade_user_payment_td/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
insert overwrite table edu.dws_trade_user_payment_td
    partition (dt = '2022-02-21')
select user_id,
       min(callback_time) payment_dt_first
from edu.dwd_trade_pay_detail_suc_inc
group by user_id;
```

（2）每日装载

``` text
insert overwrite table dws_trade_user_payment_td partition (dt='2022-02-22')
select nvl(old.user_id,npd.user_id) user_id,
       `if`(payment_dt_first is null ,callback_time,payment_dt_first ) payment_dt_first
from (
     select user_id,
           payment_dt_first
    from dws_trade_user_payment_td
    where dt=date_sub('2022-02-22',1)
)old
full outer join (
    select user_id,
           max(callback_time) callback_time
    from dwd_trade_pay_detail_suc_inc
    where dt='2022-02-22'
    group by user_id
)npd
on old.user_id=npd.user_id;
```

### 10.3.3 用户域用户粒度用户登录历史至今汇总表

**1）建表语句**

``` text
DROP TABLE IF EXISTS dws_user_user_login_td;
CREATE EXTERNAL TABLE dws_user_user_login_td
(
    `user_id`          STRING COMMENT '用户id',
    `login_last_date`  STRING COMMENT '末次登录日期',
    `user_login_count` STRING COMMENT '用户登录次数'
) COMMENT '用户域用户粒度用户登录历史至今汇总表'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/edu/dws/dws_user_user_login_td/'
    TBLPROPERTIES ('orc.compress' = 'snappy');
```

**2）数据装载**

（1）首日装载

``` text
insert overwrite table edu.dws_user_user_login_td
    partition (dt = '2022-02-21')
select ui.id,
       nvl(login_last_date, register_date) login_last_date,
       nvl(user_login_count, 1)            user_login_count
from (select id,
             date_format(create_time, 'yyyy-MM-dd') register_date
      from edu.dim_user_zip
      where dt = '9999-12-31') ui
         left join
     (
         select user_id,
                max(date_id) login_last_date,
                count(*)     user_login_count
         from edu.dwd_user_login_inc
         group by user_id
     ) login_td
     on ui.id = login_td.user_id;
```

（2）每日装载

``` text
insert overwrite table dws_user_user_login_td partition (dt='2022-02-22')
select nvl(old.user_id,nl.user_id) user_id,
       nvl(nl.date_id,old.login_last_date) login_last_date,
       nvl(old.user_login_count,0) + nvl(nl.counts,0) user_login_count
from (
     select user_id,
           login_last_date,
           user_login_count
    from dws_user_user_login_td
    where dt=date_sub('2022-02-22',1)
)old
full outer join (
    select user_id,
           max(date_id) date_id,
           count(*) counts
    from dwd_user_login_inc
    where dt='2022-02-22'
    group by user_id
)nl
on old.user_id=nl.user_id;
```

### 10.3.4 数据装载脚本

**1）首日数据装载脚本**

（1）在hadoop102的/home/atguigu/bin目录下创建dws_1d_to_dws_td_init.sh

``` bash
[zhangsan@node0 bin]$ vim dws_1d_to_dws_td_init.sh
```

（2）编写如下内容

``` text
#!/bin/bash
if [ -n "$2" ] ;then
    do_date=$2
else
    echo "请传入日期参数"
    exit
fi
APP=edu
dws_trade_user_order_td="
insert overwrite table ${APP}.dws_trade_user_order_td
    partition (dt = '$do_date')
select user_id,
       min(create_time) order_dt_first,
       max(create_time) order_dt_last
from ${APP}.dwd_trade_order_detail_inc
group by user_id;"
dws_trade_user_payment_td="
insert overwrite table ${APP}.dws_trade_user_payment_td
    partition (dt = '$do_date')
select user_id,
       min(callback_time) payment_dt_first
from ${APP}.dwd_trade_pay_detail_suc_inc
group by user_id;"
dws_user_user_login_td="
insert overwrite table ${APP}.dws_user_user_login_td
    partition (dt = '$do_date')
select ui.id,
       nvl(login_last_date, register_date) login_last_date,
       nvl(user_login_count, 1)            user_login_count
from (select id,
             date_format(create_time, 'yyyy-MM-dd') register_date
      from ${APP}.dim_user_zip
      where dt = '9999-12-31') ui
         left join
     (
         select user_id,
                max(date_id) login_last_date,
                count(*)     user_login_count
         from ${APP}.dwd_user_login_inc
         group by user_id
     ) login_td
     on ui.id = login_td.user_id;"
case $1 in
    dws_trade_user_order_td|dws_trade_user_payment_td|dws_user_user_login_td)
        eval "hive -e \"\$$1\""
    ;;
    "all" )
        hive -e "${dws_trade_user_order_td}${dws_trade_user_payment_td}${dws_user_user_login_td}"
    ;;
esac
```

（3）增加脚本执行权限

``` bash
[zhangsan@node0 bin]$ chmod +x dws_1d_to_dws_td_init.sh
```

（4）脚本用法

``` bash
[zhangsan@node0 bin]$ dws_1d_to_dws_td_init.sh all 2022-02-21
```

**2）每日数据装载脚本**

（1）在hadoop102的/home/atguigu/bin目录下创建dws_1d_to_dws_td.sh

``` bash
[zhangsan@node0 bin]$ vim dws_1d_to_dws_td.sh
```

（2）编写如下内容

``` text
#!/bin/bash
if [ -n "$2" ] ;then
    do_date=$2
else
    do_date=`date -d "-1 day" +%F`
fi
APP=edu
dws_trade_user_order_td="
insert overwrite table ${APP}.dws_trade_user_order_td partition (dt='$do_date')
select  nvl(old.user_id,nod.user_id) user_id,
        if(old.order_dt_first is null,nod.create_time,old.order_dt_first) order_dt_first,
        if(nod.create_time is null,old.order_dt_last,nod.create_time) order_dt_last
from (
     select user_id,
            max(create_time) create_time
    from ${APP}.dwd_trade_order_detail_inc
    where dt='$do_date'
    group by user_id
)nod
full outer join (
    select user_id,
           order_dt_first,
           order_dt_last
    from ${APP}.dws_trade_user_order_td
    where dt=date_sub('$do_date',1)
)old
on nod.user_id=old.user_id;"
dws_trade_user_payment_td="
insert overwrite table ${APP}.dws_trade_user_payment_td
    partition (dt = '$do_date')
select nvl(new.user_id, old.user_id),
       if((payment_dt_first is null) or (new_payment_dt_first < payment_dt_first), new_payment_dt_first,
          payment_dt_first)
from (select *
      from ${APP}.dws_trade_user_payment_td
      where dt = date_add('$do_date', -1)) old
         full outer join
     (
         select user_id,
                min(callback_time) new_payment_dt_first
         from ${APP}.dwd_trade_pay_detail_suc_inc
         where dt = '$do_date'
         group by user_id
     ) new
     on old.user_id = new.user_id;"
dws_user_user_login_td="
insert overwrite table ${APP}.dws_user_user_login_td
    partition (dt = '$do_date')
select nvl(old_user_id, new_user_id)         user_id,
       nvl(new_date, old_date)               login_last_date,
       nvl(old_count, 0) + nvl(new_count, 0) user_login_count
from (select user_id          old_user_id,
             login_last_date  old_date,
             user_login_count old_count
      from ${APP}.dws_user_user_login_td
      where dt = date_add('$do_date', -1)) old
         full outer join
     (
         select user_id      new_user_id,
                '$do_date' new_date,
                count(*)     new_count
         from ${APP}.dwd_user_login_inc
         where dt = '$do_date'
         group by user_id
     ) new
     on old_user_id = new_user_id;"
case $1 in
    dws_trade_user_order_td|dws_trade_user_payment_td|dws_user_user_login_td)
        eval "hive -e \"\$$1\""
    ;;
    "all" )
        hive -e "${dws_trade_user_order_td}${dws_trade_user_payment_td}${dws_user_user_login_td}"
    ;;
esac
```

（3）增加脚本执行权限

``` bash
[zhangsan@node0 bin]$ chmod +x dws_1d_to_dws_td.sh
```

（4）脚本用法

``` bash
[zhangsan@node0 bin]$ dws_1d_to_dws_td.sh all 2022-02-22
```
