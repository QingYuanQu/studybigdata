DROP TABLE IF EXISTS `dwd_table_process`;
CREATE TABLE `dwd_table_process` (
    `source_table` varchar(200) NOT NULL COMMENT '来源表',
    `source_type` varchar(200) NOT NULL COMMENT '来源操作类型',
    `sink_table` varchar(200) NOT NULL COMMENT '输出表',
    `sink_columns` varchar(2000) COMMENT '输出字段',
    PRIMARY KEY (`source_table`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `dwd_table_process` */
INSERT INTO `dwd_table_process`(`source_table`, `source_type`, `sink_table`, `sink_columns`) VALUES ('cart_info', 'insert', 'dwd_trade_cart_add', 'id,user_id,course_id,course_name,cart_price,session_id');
INSERT INTO `dwd_table_process`(`source_table`, `source_type`, `sink_table`, `sink_columns`) VALUES ('test_exam', 'insert', 'dwd_examination_test_paper', 'id,paper_id,user_id,score,duration_sec,create_time,submit_time,update_time');
INSERT INTO `dwd_table_process`(`source_table`, `source_type`, `sink_table`, `sink_columns`) VALUES ('test_exam_question', 'insert', 'dwd_examination_test_question', 'id,exam_id,paper_id,question_id,user_id,is_correct,score,create_time,update_time');
INSERT INTO `dwd_table_process`(`source_table`, `source_type`, `sink_table`, `sink_columns`) VALUES ('favor_info', 'insert', 'dwd_interaction_favor_add', 'id,course_id,user_id,create_time,update_time');
INSERT INTO `dwd_table_process`(`source_table`, `source_type`, `sink_table`, `sink_columns`) VALUES ('comment_info', 'insert', 'dwd_interaction_comment', 'id,user_id,chapter_id,course_id,create_time');
INSERT INTO `dwd_table_process`(`source_table`, `source_type`, `sink_table`, `sink_columns`) VALUES ('review_info', 'insert', 'dwd_interaction_review', 'id,user_id,course_id,review_stars,create_time');