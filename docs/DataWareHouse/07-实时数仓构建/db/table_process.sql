DROP TABLE IF EXISTS `table_process`;
CREATE TABLE `table_process`  (
  `source_table` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '来源表',
  `sink_table` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '输出目标表',
  `sink_columns` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '输出表字段',
  `sink_pk` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '输出表主键',
  `sink_extend` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '输出表扩展配置',
  PRIMARY KEY (`source_table`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of table_process
-- ----------------------------
INSERT INTO `table_process` VALUES ('base_category_info', 'dim_base_category_info', 'id,category_name,create_time,update_time,deleted','id', NULL);
INSERT INTO `table_process` VALUES ('base_province', 'dim_base_province', 'id,name,region_id,area_code,iso_code,iso_3166_2', 'id', NULL);
INSERT INTO `table_process` VALUES ('base_source', 'dim_base_source', 'id, source_site', 'id', NULL);
INSERT INTO `table_process` VALUES ('base_subject_info', 'dim_base_subject_info', 'id,subject_name,category_id,create_time,update_time,deleted', 'id', NULL);
INSERT INTO `table_process` VALUES ('chapter_info', 'dim_chapter_info', 'id,chapter_name,course_id,video_id,publisher_id,is_free,create_time,deleted,update_time', 'id', NULL);
INSERT INTO `table_process` VALUES ('course_info', 'dim_course_info', 'id,course_name,course_slogan,subject_id,teacher,publisher_id,chapter_num,origin_price,reduce_amount,actual_price,course_introduce,create_time,deleted,update_time', 'id', NULL);
INSERT INTO `table_process` VALUES ('knowledge_point', 'dim_knowledge_point', 'id,point_txt,point_level,course_id,chapter_id,create_time,update_time,publisher_id,deleted', 'id', NULL);
INSERT INTO `table_process` VALUES ('test_paper', 'dim_test_paper', 'id,paper_title,course_id,create_time,update_time,publisher_id,deleted', 'id', NULL);
INSERT INTO `table_process` VALUES ('test_paper_question', 'dim_test_paper_question', 'id,paper_id,question_id,score,create_time,deleted,publisher_id', 'id', NULL);
INSERT INTO `table_process` VALUES ('test_point_question', 'dim_test_point_question', 'id,point_id,question_id,create_time,publisher_id,deleted', 'id', NULL);
INSERT INTO `table_process` VALUES ('test_question_info', 'dim_test_question_info', 'id,question_txt,chapter_id,course_id,question_type,create_time,update_time,publisher_id,deleted', 'id', NULL);
INSERT INTO `table_process` VALUES ('test_question_option', 'dim_test_question_option', 'id,option_txt,question_id,is_correct,create_time,update_time,deleted', 'id', NULL);
INSERT INTO `table_process` VALUES ('user_info', 'dim_user_info', 'id,login_name,nick_name,passwd,real_name,phone_num,email,user_level,birthday,gender,create_time,operate_time,status', 'id', NULL);
INSERT INTO `table_process` VALUES ('video_info', 'dim_video_info', 'id,video_name,during_sec,video_status,video_size,video_source_id,version_id,chapter_id,course_id,publisher_id,create_time,update_time,deleted', 'id', NULL);