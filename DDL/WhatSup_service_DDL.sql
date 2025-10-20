-- 유저 TABLE
CREATE TABLE users(
  user_id BIGINT AUTO_INCREMENT UNIQUE,
  login_id varchar(20) NOT NULL UNIQUE,
  password varchar(20) NOT NULL,
  nick_name varchar(25) NOT NULL,
  role varchar(15) CHECK (role IN ('user','administrator')),
  create_at timestamp DEFAULT CURRENT_TIMESTAMP,
  update_at timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  isLogin TINYINT CHECK (isLogin IN (0,1)),
  PRIMARY KEY (user_id)
);
-- FAQ TABLE
CREATE TABLE faq (
    faq_id INT(11) NOT NULL AUTO_INCREMENT COMMENT '자주 하는 질문 아이디',
    administrator_id BIGINT NOT NULL COMMENT '관리자 아이디 (FK)',
    category VARCHAR(100) NOT NULL COMMENT '카테고리',
    question VARCHAR(255) NOT NULL COMMENT '질문',
    answer VARCHAR(2000) NOT NULL COMMENT '답변',
    PRIMARY KEY (faq_id),
    FOREIGN KEY (administrator_id) REFERENCES users(user_id)
) COMMENT '자주 하는 질문';
-- QNA 테이블
CREATE TABLE qna (
    qna_id INT(11) NOT NULL AUTO_INCREMENT COMMENT '큐엔에이 아이디',
    user_id BIGINT NOT NULL COMMENT '유저 아이디 (FK)',
    question_title VARCHAR(255) NOT NULL COMMENT '질문 제목',
    question_content VARCHAR(2000) NOT NULL COMMENT '질문 내용',
    answer_content VARCHAR(2000) NULL COMMENT '답변 내용',
    status VARCHAR(20) NOT NULL COMMENT '처리 상태',
    PRIMARY KEY (qna_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT '큐앤에이';
-- 쿠폰 정보 테이블
CREATE TABLE coupons (
    coupon_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '쿠폰 아이디',
    code VARCHAR(255) NOT NULL UNIQUE COMMENT '쿠폰 코드',
    name VARCHAR(255) NOT NULL COMMENT '쿠폰명',
    discount_value BIGINT NOT NULL COMMENT '할인 가격',
    expire_date DATE NOT NULL COMMENT '만료일',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '업데이트일',
    PRIMARY KEY (coupon_id)	
) COMMENT '쿠폰 정보';
-- 쿠폰 입력 테이블
CREATE TABLE user_coupons (
    user_coupons_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '사용자 쿠폰 아이디',
    user_id BIGINT NOT NULL COMMENT '사용자 아이디 (FK)',
    coupon_id BIGINT NOT NULL COMMENT '쿠폰 아이디 (FK)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '업데이트일',
    expired_at DATE NOT NULL COMMENT '만료일',
    used_at DATE NULL COMMENT '사용일',
    PRIMARY KEY (user_coupons_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id)
) COMMENT '쿠폰 입력';
-- 전문가 콘텐츠 테이블
CREATE TABLE expert_contents (
    content_id INT(11) NOT NULL AUTO_INCREMENT COMMENT '콘텐츠 아이디',
    administrator_id BIGINT NOT NULL COMMENT '관리자 아이디 (FK)',
    title VARCHAR(255) NOT NULL COMMENT '제목',
    video_link VARCHAR(255) NULL COMMENT '비디오 링크',
    category VARCHAR(100) NOT NULL COMMENT '카테고리',
    expert_job VARCHAR(100) NOT NULL COMMENT '전문가 직업',
    PRIMARY KEY (content_id),
    FOREIGN KEY (administrator_id) REFERENCES users(user_id)
) COMMENT '전문가 컨텐츠';
-- SNS 공유 테이블
CREATE TABLE sns_share (
    shared_id INT(11) NOT NULL AUTO_INCREMENT COMMENT '공유 아이디',
    user_id BIGINT NOT NULL COMMENT '유저 아이디 (FK)',
    shared_link VARCHAR(255) NOT NULL COMMENT '공유 링크',
    shared_platform VARCHAR(50) NOT NULL COMMENT '공유 플랫폼',
    PRIMARY KEY (shared_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT 'SNS 공유';

