-- 사용자 테이블 생성
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
-- 사용자 상세 정보 생성
CREATE TABLE user_details (
    user_id BIGINT PRIMARY KEY,                  
    name VARCHAR(30) NOT NULL,                  
    phone_number VARCHAR(11),                    
    age_code INT,                                
    gender_code VARCHAR(1),                      
    address VARCHAR(50),                       
    email VARCHAR(30),                          
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT user_details_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE      -- 사용자 삭제 시 세부정보도 삭제
) ;
-- 제품 테이블 생성
CREATE TABLE products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    min_age INT DEFAULT 0,
    max_age INT DEFAULT 150,
    gender CHAR(1) DEFAULT 'B', 
    price INT NOT NULL,
    thumbnail_img varchar(255),
    stock int NOT NULL DEFAULT 0,
    description varchar(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP       
);

-- 장바구니 상품 테이블 생성
CREATE TABLE cart_products(
	cart_product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	product_id BIGINT NOT NULL,
	user_id BIGINT NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	is_selected TINYINT(1) NOT NULL DEFAULT 1, -- boolean
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(product_id) REFERENCES products(product_id),
	CONSTRAINT cp_cart
		FOREIGN KEY(user_id) REFERENCES users(user_id)
		ON DELETE CASCADE, -- 장바구니 삭제/변경시 장바구니 상품도 삭제
	UNIQUE KEY uq_cart_product(user_id, product_id) 
	-- 장바구니 상품을 여러개 넣지 않도록(숫자변경만 되도록), 기본키로 할까 고민
);
-- 주문 테이블 생성
CREATE TABLE orders(
	order_id BIGINT PRIMARY KEY AUTO_INCREMENT, 
	user_id BIGINT NOT NULL,
	status varchar(10) NOT NULL DEFAULT '출고전',
	receiver varchar(20) NOT NULL,
	phone_number varchar(11) NOT NULL,
	address varchar(50) NOT NULL,
	delivered_at date NULL, -- 배송예정일
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
  	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,     
	FOREIGN KEY(user_id) REFERENCES users(user_id)
);
-- 주문 상품 테이블 생성, 카운트 추가 고민!
CREATE TABLE order_products(
	order_product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	order_id BIGINT NOT NULL,
	product_id BIGINT NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	price INT NOT NULL,
	FOREIGN KEY(order_id) REFERENCES orders(order_id)
		ON DELETE CASCADE,
	FOREIGN KEY(product_id) REFERENCES products(product_id)
		ON DELETE RESTRICT ON UPDATE CASCADE, -- 상품 삭제 시 주문 상세 테이블 보호
	UNIQUE KEY uq_order_product(order_id, product_id) 
	-- 주문 상품을 여러개 넣지 않도록(숫자변경만 되도록)
);
-- 반품 요청 테이블 생성
CREATE TABLE return_requests(
	return_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	order_product_id BIGINT NOT NULL,
	comment varchar(500) NULL, -- 고민!
	return_status varchar(10) NOT null,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,       
	FOREIGN KEY(order_product_id) REFERENCES order_products(order_product_id)
);
-- 반품 이미지 생성
CREATE TABLE return_images(
	return_image_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	return_id BIGINT NOT NULL,
	image VARCHAR(500) NOT NULL, 
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN key(return_id) REFERENCES return_requests(return_id)
		ON DELETE CASCADE
);

-- 취소 요청 테이블 생성
CREATE TABLE withdraw_requests(
	withdraw_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	order_id BIGINT NOT NULL,
	comment varchar(500) NULL, -- 고민!
	withdraw_status varchar(10) NOT null,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,       
	FOREIGN KEY(order_id) REFERENCES orders(order_id)
);


