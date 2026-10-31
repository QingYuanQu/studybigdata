CREATE TABLE `base_category_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `category_name` varchar(200) DEFAULT NULL COMMENT '分类名称',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='商品分类表';

CREATE TABLE `base_province` (
  `id` bigint(20) NOT NULL COMMENT 'id',
  `name` varchar(20) DEFAULT NULL COMMENT '省名称',
  `region_id` varchar(20) DEFAULT NULL COMMENT '大区id',
  `area_code` varchar(20) DEFAULT NULL COMMENT '行政区位码',
  `iso_code` varchar(20) DEFAULT NULL COMMENT '国际编码',
  `iso_3166_2` varchar(20) DEFAULT NULL COMMENT 'ISO3166编码',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='省份信息表';

CREATE TABLE `base_source` (
  `id` bigint(20) NOT NULL,
  `source_site` varchar(20) DEFAULT NULL,
  `source_url` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='来源渠道表';

CREATE TABLE `base_subject_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `subject_name` varchar(200) DEFAULT NULL COMMENT '科目名称',
  `category_id` bigint(20) DEFAULT NULL COMMENT '分类',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='学科信息表';

CREATE TABLE `cart_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `course_name` varchar(200) DEFAULT NULL COMMENT '课程名称(冗余)',
  `cart_price` decimal(10,2) DEFAULT NULL COMMENT '购物车价格',
  `img_url` varchar(200) DEFAULT NULL COMMENT '课程封面图',
  `session_id` varchar(200) DEFAULT NULL COMMENT '会话id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  `sold` varchar(2) DEFAULT NULL COMMENT '是否已售出',
  PRIMARY KEY (`id`),
  KEY `idx_uid` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4745 DEFAULT CHARSET=utf8 COMMENT='购物车表';

CREATE TABLE `chapter_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `chapter_name` varchar(200) DEFAULT NULL COMMENT '章节名称',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `video_id` bigint(20) DEFAULT NULL COMMENT '视频id',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `is_free` varchar(2) DEFAULT NULL COMMENT '是否免费试看',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_cid` (`course_id`),
  KEY `idx_vid` (`video_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26306 DEFAULT CHARSET=utf8 COMMENT='课程章节表';

CREATE TABLE `comment_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `chapter_id` bigint(20) DEFAULT NULL COMMENT '章节id',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `comment_txt` varchar(2000) DEFAULT NULL COMMENT '评论内容',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` varchar(1) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1632 DEFAULT CHARSET=utf8 COMMENT='课程评论表';

CREATE TABLE `course_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `course_name` varchar(200) DEFAULT NULL COMMENT '课程名称',
  `course_slogan` varchar(200) DEFAULT NULL COMMENT '课程标语',
  `course_cover_url` varchar(200) DEFAULT NULL COMMENT '课程封面图',
  `subject_id` bigint(20) DEFAULT NULL COMMENT '学科id',
  `teacher` varchar(4000) DEFAULT NULL COMMENT '讲师名称',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `chapter_num` bigint(20) DEFAULT NULL COMMENT '章节数',
  `origin_price` decimal(16,2) DEFAULT NULL COMMENT '原价',
  `reduce_amount` decimal(16,2) DEFAULT NULL COMMENT '优惠金额',
  `actual_price` decimal(16,2) DEFAULT NULL COMMENT '实际价格',
  `course_introduce` varchar(2000) DEFAULT NULL COMMENT '课程介绍',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=453 DEFAULT CHARSET=utf8 COMMENT='课程信息表';

CREATE TABLE `favor_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7294 DEFAULT CHARSET=utf8 COMMENT='用户收藏表';

CREATE TABLE `knowledge_point` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `point_txt` varchar(4000) DEFAULT NULL COMMENT '知识点内容',
  `point_level` bigint(20) DEFAULT NULL COMMENT '知识点级别',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `chapter_id` bigint(20) DEFAULT NULL COMMENT '章节id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='知识点表';

CREATE TABLE `order_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `course_name` varchar(4000) DEFAULT NULL COMMENT '课程名称',
  `order_id` bigint(20) DEFAULT NULL COMMENT '订单id',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `origin_amount` decimal(16,2) DEFAULT NULL COMMENT '原价',
  `coupon_reduce` decimal(16,2) DEFAULT NULL COMMENT '优惠券减免金额',
  `final_amount` decimal(16,2) DEFAULT NULL COMMENT '最终金额',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_oid_cid` (`order_id`,`course_id`),
  KEY `idx_cid` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17384 DEFAULT CHARSET=utf8 COMMENT='订单明细表';

CREATE TABLE `order_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `origin_amount` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `coupon_reduce` decimal(10,2) DEFAULT NULL COMMENT '优惠券减免',
  `final_amount` decimal(10,2) DEFAULT NULL COMMENT '最终金额',
  `order_status` varchar(20) DEFAULT NULL COMMENT '订单状态',
  `out_trade_no` varchar(50) DEFAULT NULL COMMENT '第三方交易单号',
  `trade_body` varchar(200) DEFAULT NULL COMMENT '订单描述',
  `session_id` varchar(100) DEFAULT NULL COMMENT '会话id',
  `province_id` bigint(20) DEFAULT NULL COMMENT '省份id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `expire_time` datetime DEFAULT NULL COMMENT '订单过期时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_uid` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16824 DEFAULT CHARSET=utf8 COMMENT='订单信息表';

CREATE TABLE `payment_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `out_trade_no` varchar(50) DEFAULT NULL COMMENT '对外业务编号',
  `order_id` bigint(20) DEFAULT NULL COMMENT '订单id',
  `alipay_trade_no` varchar(50) DEFAULT NULL COMMENT '支付宝交易单号',
  `total_amount` decimal(10,0) DEFAULT NULL COMMENT '支付金额',
  `trade_body` varchar(200) DEFAULT NULL COMMENT '交易内容',
  `payment_type` varchar(20) DEFAULT NULL COMMENT '支付方式',
  `payment_status` varchar(20) DEFAULT NULL COMMENT '支付状态',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `callback_content` varchar(1000) DEFAULT NULL COMMENT '支付回调信息',
  `callback_time` datetime DEFAULT NULL COMMENT '回调时间',
  PRIMARY KEY (`id`),
  KEY `idx_oid` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9315 DEFAULT CHARSET=utf8 COMMENT='支付信息表';

CREATE TABLE `review_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `review_txt` varchar(4000) DEFAULT NULL COMMENT '评价内容',
  `review_stars` bigint(20) DEFAULT NULL COMMENT '评价星级',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` varchar(1) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_uid` (`user_id`,`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1634 DEFAULT CHARSET=utf8 COMMENT='课程评价表';

CREATE TABLE `test_exam` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `paper_id` bigint(20) DEFAULT NULL COMMENT '试卷id',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `score` decimal(10,2) DEFAULT NULL COMMENT '得分',
  `duration_sec` bigint(20) DEFAULT NULL COMMENT '考试时长(秒)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_pid` (`paper_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1540 DEFAULT CHARSET=utf8 COMMENT='考试记录表';

CREATE TABLE `test_exam_question` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `exam_id` bigint(20) DEFAULT NULL COMMENT '考试记录id',
  `paper_id` bigint(20) DEFAULT NULL COMMENT '试卷id',
  `question_id` bigint(20) DEFAULT NULL COMMENT '题目id',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `answer` varchar(2000) DEFAULT NULL COMMENT '用户答案',
  `is_correct` varchar(2) DEFAULT NULL COMMENT '是否正确',
  `score` decimal(16,2) DEFAULT NULL COMMENT '本题得分',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_eid` (`exam_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22705 DEFAULT CHARSET=utf8 COMMENT='考试题目答题记录表';

CREATE TABLE `test_paper` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `paper_title` varchar(200) DEFAULT NULL COMMENT '试卷标题',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_cid` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=217 DEFAULT CHARSET=utf8 COMMENT='试卷表';

CREATE TABLE `test_paper_question` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `paper_id` bigint(20) DEFAULT NULL COMMENT '试卷id',
  `question_id` bigint(20) DEFAULT NULL COMMENT '题目id',
  `score` decimal(10,2) DEFAULT NULL COMMENT '分值',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_pid` (`paper_id`,`question_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3225 DEFAULT CHARSET=utf8 COMMENT='试卷题目关联表';

CREATE TABLE `test_point_question` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `point_id` bigint(20) DEFAULT NULL COMMENT '知识点id',
  `question_id` bigint(20) DEFAULT NULL COMMENT '题目id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='知识点与题目关联表';

CREATE TABLE `test_question_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `question_txt` varchar(4000) DEFAULT NULL COMMENT '题目内容',
  `chapter_id` bigint(20) DEFAULT NULL COMMENT '章节id',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `question_type` bigint(20) DEFAULT NULL COMMENT '题目类型',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_chid` (`chapter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2609 DEFAULT CHARSET=utf8 COMMENT='题目信息表';

CREATE TABLE `test_question_option` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `option_txt` varchar(2000) DEFAULT NULL COMMENT '选项内容',
  `question_id` bigint(20) DEFAULT NULL COMMENT '题目id',
  `is_correct` varchar(2) DEFAULT NULL COMMENT '是否正确答案',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_qid` (`question_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9118 DEFAULT CHARSET=utf8 COMMENT='题目选项表';

CREATE TABLE `user_chapter_process` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `chapter_id` bigint(20) DEFAULT NULL COMMENT '章节id',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `position_sec` bigint(20) DEFAULT NULL COMMENT '播放位置(秒)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1691 DEFAULT CHARSET=utf8 COMMENT='用户章节学习进度表';

CREATE TABLE `user_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `login_name` varchar(200) DEFAULT NULL COMMENT '登录名',
  `nick_name` varchar(200) DEFAULT NULL COMMENT '昵称',
  `passwd` varchar(200) DEFAULT NULL COMMENT '密码',
  `real_name` varchar(200) DEFAULT NULL COMMENT '真实姓名',
  `phone_num` varchar(200) DEFAULT NULL COMMENT '手机号',
  `email` varchar(200) DEFAULT NULL COMMENT '邮箱',
  `head_img` varchar(200) DEFAULT NULL COMMENT '头像url',
  `user_level` varchar(200) DEFAULT NULL COMMENT '用户等级',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `gender` varchar(1) DEFAULT NULL COMMENT '性别(M男/F女)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operate_time` datetime DEFAULT NULL COMMENT '最后操作时间',
  `status` varchar(200) DEFAULT NULL COMMENT '账号状态',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8 COMMENT='用户信息表';

CREATE TABLE `video_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `video_name` varchar(200) DEFAULT NULL COMMENT '视频名称',
  `during_sec` bigint(20) DEFAULT NULL COMMENT '视频时长(秒)',
  `video_status` varchar(4000) DEFAULT NULL COMMENT '视频状态(未上传/上传中/上传完成)',
  `video_size` bigint(20) DEFAULT NULL COMMENT '视频大小(字节)',
  `video_url` varchar(500) DEFAULT NULL COMMENT '视频存储路径',
  `video_source_id` varchar(200) DEFAULT NULL COMMENT '云端资源id',
  `version_id` bigint(20) DEFAULT NULL COMMENT '版本号',
  `chapter_id` bigint(20) DEFAULT NULL COMMENT '章节id',
  `course_id` bigint(20) DEFAULT NULL COMMENT '课程id',
  `publisher_id` bigint(20) DEFAULT NULL COMMENT '发布者id',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted` varchar(2) DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`),
  KEY `idx_chid` (`chapter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5411 DEFAULT CHARSET=utf8 COMMENT='视频信息表';

CREATE TABLE `vip_change_detail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户id',
  `from_vip` bigint(20) DEFAULT NULL COMMENT '变更前VIP等级',
  `to_vip` bigint(20) DEFAULT NULL COMMENT '变更后VIP等级',
  `create_time` datetime DEFAULT NULL COMMENT '变更时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9248 DEFAULT CHARSET=utf8 COMMENT='用户VIP等级变更记录表';