# 第7章 数仓开发之ODS层

ODS层的设计要点如下：

（1）ODS层的表结构设计依托于从业务系统同步过来的数据结构。

（2）ODS层要保存全部历史数据，故其压缩格式应选择压缩比较高的，此处选择gzip。

（3）ODS层表名的命名规范为：ods_表名_单分区增量全量标识（inc/full）。

## 7.1 日志表

**1）建表语句**

``` hive
DROP TABLE IF EXISTS ods_log_inc;
create external table ods_log_inc
(
    `common`   STRUCT<ar :STRING,sid :STRING,ba :STRING,ch :STRING,is_new :STRING,md :STRING,mid :STRING,os :STRING,uid :STRING,vc :STRING,sc :STRING> COMMENT '公共信息',
    `page`     STRUCT<during_time :STRING,item :STRING,item_type :STRING,last_page_id :STRING,page_id :STRING,source_type :STRING> COMMENT '页面信息',
    `actions`  ARRAY<STRUCT<action_id:STRING,item:STRING,item_type:STRING,ts:BIGINT>> COMMENT '动作信息',
    `displays` ARRAY<STRUCT<display_type :STRING,item :STRING,item_type :STRING,`order` :STRING,pos_id :STRING>> COMMENT '曝光信息',
    `start`    STRUCT<entry :STRING,loading_time :BIGINT,open_ad_id :BIGINT,open_ad_ms :BIGINT,open_ad_skip_ms :BIGINT,first_open :STRING> COMMENT '启动信息',
    `err` 		STRUCT<error_code:BIGINT,msg:STRING> COMMENT '错误信息',
    `appVideo` 	STRUCT<video_id:STRING, position_sec:BIGINT, play_sec: BIGINT> COMMENT '视频播放信息',
    `ts` 		BIGINT COMMENT '时间戳'
) COMMENT '日志增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_log_inc/';
```

**2）数据装载**

``` hive
load data inpath '/origin_data/edu/log/edu_log/2022-02-21' into table edu.ods_log_inc partition(dt='2022-02-21');
```

**3）每日数据装载脚本**

（1）在hadoop102的/home/atguigu/bin目录下创建hdfs_to_ods_log.sh

``` bash
[zhangsan@node0 bin]$ vim hdfs_to_ods_log.sh
```

（2）编写如下内容

``` shell
#!/bin/bash
# 定义变量方便修改
APP="edu"
# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
if [ -n "$1" ] ;then
   do_date=$1
else
   do_date=`date -d "-1 day" +%F`
fi
echo ================== 日志日期为 $do_date ==================
sql="
load data inpath '/origin_data/edu/log/edu_log/$do_date' into table ${APP}.ods_log_inc partition(dt='$do_date');
"
hive -e "$sql"
```

（3）增加脚本执行权限

``` bash
[zhangsan@node0 bin]$ chmod +x hdfs_to_ods_log.sh
```

（4）脚本用法

``` bash
[zhangsan@node0 bin]$ hdfs_to_ods_log.sh 2022-02-21
```

## 7.2 业务表

### 7.2.1 创建分类信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_base_category_info_full`;
CREATE EXTERNAL TABLE `ods_base_category_info_full`
(
    `id` STRING COMMENT '编号',
    `category_name` STRING COMMENT '分类名称',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '分类信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_category_info_full/';
```

### 7.2.2 创建来源信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_base_source_full`;
CREATE EXTERNAL TABLE `ods_base_source_full`
(
    `id` STRING COMMENT '编号',
    `source_site` STRING COMMENT '来源',
    `source_url` STRING COMMENT '来源网址'
) COMMENT '来源信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_source_full/';
```

### 7.2.3 创建省份表（全量）

``` hive
DROP TABLE IF EXISTS `ods_base_province_full`;
CREATE EXTERNAL TABLE `ods_base_province_full`
(
    `id` STRING COMMENT '编号',
    `name` STRING COMMENT '省名称',
    `region_id` STRING COMMENT '地区id',
    `area_code` STRING COMMENT '行政区位码',
    `iso_code` STRING COMMENT '国际编码',
    `iso_3166_2` STRING COMMENT 'ISO3166编码'
) COMMENT '省份全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_province_full/';
```

### 7.2.4 创建科目信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_base_subject_info_full`;
CREATE EXTERNAL TABLE `ods_base_subject_info_full`
(
    `id` STRING COMMENT '编号',
    `subject_name` STRING COMMENT '科目名称',
    `category_id` STRING COMMENT '分类id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '科目信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_base_subject_info_full/';
```

### 7.2.5 创建购物车表（全量）

``` hive
DROP TABLE IF EXISTS `ods_cart_info_full`;
CREATE EXTERNAL TABLE `ods_cart_info_full`
(
    `id` STRING COMMENT '编号',
    `user_id` STRING COMMENT '用户id',
    `course_id` STRING COMMENT '课程id',
    `course_name` STRING COMMENT '课程名称 (冗余)',
    `cart_price` DEC(16, 2) COMMENT '放入购物车时价格',
    `img_url` STRING COMMENT '图片文件',
    `session_id` STRING COMMENT '会话id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '修改时间',
    `deleted` STRING COMMENT '是否已删',
    `sold` STRING COMMENT '是否已售'
) COMMENT '购物车全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_cart_info_full/';
```

### 7.2.6 创建章节信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_chapter_info_full`;
CREATE EXTERNAL TABLE `ods_chapter_info_full`
(
    `id` STRING COMMENT '编号',
    `chapter_name` STRING COMMENT '章节名称',
    `course_id` STRING COMMENT '课程id',
    `video_id` STRING COMMENT '视频id',
    `publisher_id` STRING COMMENT '发布者id',
    `is_free` STRING COMMENT '是否免费',
    `create_time` STRING COMMENT '创建时间',
    `deleted` STRING COMMENT '是否删除',
    `update_time` STRING COMMENT '更新时间'
) COMMENT '章节信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_chapter_info_full/';
```

### 7.2.7 创建课程信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_course_info_full`;
CREATE EXTERNAL TABLE `ods_course_info_full`
(
    `id` STRING COMMENT '编号',
    `course_name` STRING COMMENT '课程名称',
    `course_slogan` STRING COMMENT '课程标语',
    `course_cover_url` STRING COMMENT '课程封面',
    `subject_id` STRING COMMENT '学科id',
    `teacher` STRING COMMENT '讲师名称',
    `publisher_id` STRING COMMENT '发布者id',
    `chapter_num` BIGINT COMMENT '章节数',
    `origin_price` DECIMAL(16, 2) COMMENT '价格',
    `reduce_amount` DECIMAL(16, 2) COMMENT '优惠金额',
    `actual_price` DECIMAL(16, 2) COMMENT '实际价格',
    `course_introduce` STRING COMMENT '课程介绍',
    `create_time` STRING COMMENT '创建时间',
    `deleted` STRING COMMENT '是否删除',
    `update_time` STRING COMMENT '更新时间'
) COMMENT '课程信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_course_info_full/';
```

### 7.2.8 创建知识点信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_knowledge_point_full`;
CREATE EXTERNAL TABLE `ods_knowledge_point_full`
(
    `id` STRING COMMENT '编号',
    `point_txt` STRING COMMENT '知识点内容  ',
    `point_level` STRING COMMENT '知识点级别',
    `course_id` STRING COMMENT '课程id',
    `chapter_id` STRING COMMENT '章节id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '修改时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '知识点信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_knowledge_point_full/';
```

### 7.2.9 创建试卷表（全量）

``` hive
DROP TABLE IF EXISTS `ods_test_paper_full`;
CREATE EXTERNAL TABLE `ods_test_paper_full`
(
    `id` STRING COMMENT '编号',
    `paper_title` STRING COMMENT '试卷名称',
    `course_id` STRING COMMENT '课程id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '试卷全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_paper_full/';
```

### 7.2.10 创建试卷题目表（全量）

``` hive
DROP TABLE IF EXISTS `ods_test_paper_question_full`;
CREATE EXTERNAL TABLE `ods_test_paper_question_full`
(
    `id` STRING COMMENT '编号',
    `paper_id` STRING COMMENT '试卷id',
    `question_id` STRING COMMENT '题目id',
    `score` DECIMAL(16, 2) COMMENT '得分',
    `create_time` STRING COMMENT '创建时间',
    `deleted` STRING COMMENT '是否删除',
    `publisher_id` STRING COMMENT '发布者id'
) COMMENT '试卷题目全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_paper_question_full/';
```

### 7.2.11 创建知识点题目表（全量）

``` hive
DROP TABLE IF EXISTS `ods_test_point_question_full`;
CREATE EXTERNAL TABLE `ods_test_point_question_full`
(
    `id` STRING COMMENT '编号',
    `point_id` STRING COMMENT '知识点id',
    `question_id` STRING COMMENT '题目id',
    `create_time` STRING COMMENT '创建时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '知识点题目全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_point_question_full/';
```

### 7.2.12 创建题目信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_test_question_info_full`;
CREATE EXTERNAL TABLE `ods_test_question_info_full`
(
    `id` STRING COMMENT '编号',
    `question_txt` STRING COMMENT '题目内容',
    `chapter_id` STRING COMMENT '章节id',
    `course_id` STRING COMMENT '课程id',
    `question_type` STRING COMMENT '题目类型',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `publisher_id` STRING COMMENT '发布者id',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '题目信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_question_info_full/';
```

### 7.2.13 创建用户章节进度表（全量）

``` hive
DROP TABLE IF EXISTS `ods_user_chapter_process_full`;
CREATE EXTERNAL TABLE `ods_user_chapter_process_full`
(
    `id` STRING COMMENT '编号',
    `course_id` STRING COMMENT '课程id',
    `chapter_id` STRING COMMENT '章节id',
    `user_id` STRING COMMENT '用户id',
    `position_sec` BIGINT COMMENT '时长位置',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '用户章节进度全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_user_chapter_process_full/';
```

### 7.2.14 创建题目选项表（全量）

``` hive
DROP TABLE IF EXISTS `ods_test_question_option_full`;
CREATE EXTERNAL TABLE `ods_test_question_option_full`
(
    `id` STRING COMMENT '编号',
    `option_txt` STRING COMMENT '选项内容',
    `question_id` STRING COMMENT '题目id',
    `is_correct` STRING COMMENT '是否正确',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '题目选项全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_test_question_option_full/';
```

### 7.2.15 创建视频信息表（全量）

``` hive
DROP TABLE IF EXISTS `ods_video_info_full`;
CREATE EXTERNAL TABLE `ods_video_info_full`
(
    `id` STRING COMMENT '编号',
    `video_name` STRING COMMENT '视频名称',
    `during_sec` BIGINT COMMENT '时长',
    `video_status` STRING COMMENT '状态 未上传，上传中，上传完',
    `video_size` BIGINT COMMENT '大小',
    `video_url` STRING COMMENT '视频存储路径',
    `video_source_id` STRING COMMENT '云端资源编号',
    `version_id` STRING COMMENT '版本号',
    `chapter_id` STRING COMMENT '章节id',
    `course_id` STRING COMMENT '课程id',
    `publisher_id` STRING COMMENT '发布者id',
    `create_time` STRING COMMENT '创建时间',
    `update_time` STRING COMMENT '更新时间',
    `deleted` STRING COMMENT '是否删除'
) COMMENT '视频信息全量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
        NULL DEFINED AS ''
    LOCATION '/warehouse/edu/ods/ods_video_info_full/';
```

### 7.2.16 创建购物车表（增量）

``` hive
DROP TABLE IF EXISTS ods_cart_info_inc;
CREATE EXTERNAL TABLE ods_cart_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, user_id : STRING, course_id : STRING, course_name : DEC(16, 2), cart_price : DECIMAL(16, 2), img_url : STRING, session_id : STRING, create_time : STRING, update_time : STRING, deleted : STRING, sold : STRING> COMMENT '数据',
    `old` MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '购物车增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_cart_info_inc/';
```

### 7.2.17 创建章节评价表（增量）

``` hive
DROP TABLE IF EXISTS ods_comment_info_inc;
CREATE EXTERNAL TABLE ods_comment_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, user_id : STRING, chapter_id : STRING, course_id : STRING, comment_txt : STRING, create_time :STRING, deleted : STRING> COMMENT '数据',
    `old` MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '章节评价增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_comment_info_inc/';
```

### 7.2.18 创建收藏表（增量）

``` hive
DROP TABLE IF EXISTS ods_favor_info_inc;
CREATE EXTERNAL TABLE ods_favor_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, course_id : STRING, user_id : STRING, create_time : STRING, update_time : STRING, deleted : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '收藏增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_favor_info_inc/';
```

### 7.2.19 创建订单明细表（增量）

``` hive
DROP TABLE IF EXISTS ods_order_detail_inc;
CREATE EXTERNAL TABLE ods_order_detail_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, course_id : STRING, course_name : STRING, order_id : STRING, user_id : STRING, origin_amount : DECIMAL(16, 2), coupon_reduce : DECIMAL(16, 2), final_amount : DECIMAL(16, 2), create_time : STRING, update_time : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '订单明细增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_order_detail_inc/';
```

### 7.2.20 创建订单表（增量）

``` hive
DROP TABLE IF EXISTS ods_order_info_inc;
CREATE EXTERNAL TABLE ods_order_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : String, user_id : String, origin_amount : DECIMAL(16, 2), coupon_reduce : DECIMAL(16, 2), final_amount : DECIMAL(16, 2), order_status : String, out_trade_no : String, trade_body : String, session_id : String, province_id  : String, create_time : String, expire_time : String, update_time : String> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '订单增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_order_info_inc/';
```

### 7.2.21 创建支付表（增量）

``` hive
DROP TABLE IF EXISTS ods_payment_info_inc;
CREATE EXTERNAL TABLE ods_payment_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, out_trade_no : STRING, order_id : STRING, alipay_trade_no : STRING, total_amount : DECIMAL(16, 2), trade_body : STRING, payment_type : STRING, payment_status : STRING, create_time : STRING, update_time : STRING, callback_content : STRING, callback_time : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '支付增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_payment_info_inc/';
```

### 7.2.22 创建课程评价表（增量）

``` hive
DROP TABLE IF EXISTS ods_review_info_inc;
CREATE EXTERNAL TABLE ods_review_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, user_id : STRING, course_id : STRING, review_txt : STRING, review_stars : STRING, create_time : STRING, deleted : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '课程评价增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_review_info_inc/';
```

### 7.2.23 创建考试表（增量）

``` hive
DROP TABLE IF EXISTS ods_test_exam_inc;
CREATE EXTERNAL TABLE ods_test_exam_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, paper_id : STRING, user_id : STRING, score : DECIMAL(16, 2), duration_sec : BIGINT, create_time : STRING, submit_time : STRING, update_time : STRING, deleted : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '考试增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_test_exam_inc/';
```

### 7.2.24 创建用户表（增量）

``` hive
DROP TABLE IF EXISTS ods_user_info_inc;
CREATE EXTERNAL TABLE ods_user_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, login_name : STRING, nick_name : STRING, passwd : STRING, real_name : STRING, phone_num : STRING, email : STRING, head_img : STRING, user_level : STRING, birthday : STRING, gender : STRING, create_time : STRING, operate_time : STRING, status : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '用户增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_user_info_inc/';
```

### 7.2.25 创建VIP等级变动明细表（增量）

``` hive
DROP TABLE IF EXISTS ods_vip_change_detail_inc;
CREATE EXTERNAL TABLE ods_vip_change_detail_inc
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT<id : STRING, user_id : STRING, from_vip : STRING, to_vip : STRING, create_time : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT 'VIP等级变动明细增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_vip_change_detail_inc/';
```

### 7.2.26 创建考试题目表（增量）

``` hive
DROP TABLE IF EXISTS `ods_test_exam_question_inc`;
CREATE EXTERNAL TABLE `ods_test_exam_question_inc`
(
    `type` STRING COMMENT '变动类型',
    `ts` STRING COMMENT '变动时间',
    `data` STRUCT< id : STRING, exam_id : STRING, paper_id : STRING, question_id : STRING,user_id : STRING, answer : STRING, is_correct : STRING,score : decimal(16, 2), create_time : STRING,update_time : STRING,deleted : STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '考试题目增量表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
    LOCATION '/warehouse/edu/ods/ods_test_exam_question_inc/';
```

### 7.2.27 数据装载脚本

**1）在hadoop102的/home/atguigu/bin目录下创建hdfs_to_ods_db.sh**

``` bash
[zhangsan@node0 bin]$ vim hdfs_to_ods_db.sh
```

**2）编写如下内容**

``` shell
#!/bin/bash
APP='edu'
if [ -n "$2" ] ;then
   do_date=$2
else
   do_date=`date -d '-1 day' +%F`
fi
load_data(){
    sql=""
    for i in $*; do
        #判断路径是否存在
        hadoop fs -test -e /origin_data/edu/db/${i:4}/$do_date
        #路径存在方可装载数据
        if [[ $? = 0 ]]; then
            sql=$sql"load data inpath '/origin_data/edu/db/${i:4}/$do_date' OVERWRITE into table ${APP}.${i} partition(dt='$do_date');"
        fi
    done
    hive -e "$sql"
}
case $1 in
    ods_base_category_info_full | ods_base_province_full | ods_base_source_full | ods_base_subject_info_full | ods_cart_info_full | ods_cart_info_inc | ods_chapter_info_full | ods_comment_info_inc | ods_course_info_full | ods_favor_info_inc | ods_knowledge_point_full | ods_order_detail_inc | ods_order_info_inc | ods_payment_info_inc | ods_review_info_inc | ods_test_exam_inc | ods_test_exam_question_inc | ods_test_paper_full | ods_test_paper_question_full | ods_test_point_question_full | ods_test_question_info_full | ods_test_question_option_full | ods_user_chapter_process_full | ods_user_info_inc | ods_video_info_full | ods_vip_change_detail_inc)
        load_data $1
    ;;
    "all")
        load_data ods_base_category_info_full ods_base_province_full ods_base_source_full ods_base_subject_info_full ods_cart_info_full ods_cart_info_inc ods_chapter_info_full ods_comment_info_inc ods_course_info_full ods_favor_info_inc ods_knowledge_point_full ods_order_detail_inc ods_order_info_inc ods_payment_info_inc ods_review_info_inc ods_test_exam_inc ods_test_exam_question_inc ods_test_paper_full ods_test_paper_question_full ods_test_point_question_full ods_test_question_info_full ods_test_question_option_full ods_user_chapter_process_full ods_user_info_inc ods_video_info_full ods_vip_change_detail_inc
    ;;
esac
```

**3）增加脚本执行权限**

``` bash
[zhangsan@node0 bin]$ chmod +x hdfs_to_ods_db.sh
```

**4）脚本用法**

``` bash
[zhangsan@node0 bin]$ hdfs_to_ods_db.sh all 2022-02-21
```
