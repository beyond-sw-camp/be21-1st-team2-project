-- carts

-- [확인]user1 카트 확인
SELECT * FROM cart_products WHERE user_id = 1;

-- 카드 담기(중복된 품목은 quantity만 변경) *
INSERT INTO cart_products (product_id, user_id, quantity)
VALUES
(1,1,1)
ON DUPLICATE KEY UPDATE
  quantity = quantity + VALUES(quantity),
  is_selected = VALUES(is_selected),   
  created_at = now();

INSERT INTO cart_products (product_id, user_id, quantity)
VALUES (1,1,1);

-- 장바구니 내 수량 변경(수량 입력) *
UPDATE cart_products c
JOIN products p ON c.product_id = p.product_id 
SET c.quantity = 3 -- 수량 입력
WHERE c.user_id = 1 AND c.product_id = 1 AND 3 <= p.stock; -- 예시 사용자, 상품 아이디


-- 장바구니 내 수량 변경(+ 버튼) *
UPDATE cart_products c
JOIN products p ON c.product_id = p.product_id 
SET c.quantity = c.quantity + 1
WHERE c.user_id = 1 AND c.product_id = 1 AND c.quantity + 1 <= p.stock; -- 제품 재고까지 담을 수 있음

-- 장바구니 내 수량 변경(- 버튼) *
UPDATE cart_products
SET quantity = quantity - 1
WHERE user_id = 1 AND product_id = 1 AND quantity -1 >= 1; -- 수량 1까지만 줄일 수 있음

-- 장바구니 상품 삭제 
DELETE 
FROM cart_products 
WHERE user_id = 1 AND product_id = 13; -- 예시 사용자, 상품 아이디

-- 장바구니 전체 선택 *
UPDATE cart_products
SET is_selected = 1
WHERE user_id = 1; -- user_id 예시

-- 장바구니 전체 해제
UPDATE cart_products
SET is_selected = 0
WHERE user_id = 1; -- user_id 예시

-- 장바구니 특정 상품 선택
UPDATE cart_products
SET is_selected = 1
WHERE user_id = 1 AND product_id = 12; -- 예시 사용자, 상품 아이디

-- 장바구니 특정 상품 해제 *
UPDATE cart_products
SET is_selected = 0
WHERE user_id = 1 AND product_id = 59; -- 예시 사용자, 상품 아이디

-- 선택 상품 합계 *
SELECT sum(p.price * c.quantity ) AS '상품 합계'
FROM cart_products c
JOIN products p ON c.product_id = p.product_id 
WHERE c.is_selected = 1 AND c.user_id = 1;


-- orders, 트랜잭션으로 해야 동시 주문 재고 데이터 정합성 완벽 -> 변경 고민!
 
-- [확인] 
SELECT * FROM orders WHERE user_id = 1;
SELECT * FROM order_products WHERE order_id = 39;
SELECT * FROM order_products WHERE order_id = 31;
SELECT stock FROM products WHERE product_id = 1;


-- 주문 ========================================================
-- 선택상품 기반 주문 *
DELIMITER //

CREATE PROCEDURE create_order_cart(
	IN p_user_id BIGINT,
	IN p_receiver varchar(30),
	IN p_phone_number varchar(11),
	IN p_address varchar(50),
	OUT p_order BIGINT
)
BEGIN
	DECLARE count_o INT DEFAULT 0;
	
	START TRANSACTION;

	-- 받는 사람 정보
	INSERT INTO orders (user_id, status, receiver, phone_number, address, delivered_at)
	values(p_user_id, '출고전', p_receiver, p_phone_number, p_address, DATE_ADD(CURDATE(), INTERVAL 3 DAY));

	SET p_order = LAST_INSERT_ID();

	-- 장바구니 선택된 상품 복사
	INSERT INTO order_products(order_id, product_id, quantity, price)
	SELECT p_order, cp.product_id, cp.quantity, p.price 
	FROM cart_products cp
	JOIN products p ON cp.product_id = p.product_id
	WHERE cp.user_id = p_user_id AND cp.is_selected = 1 AND p.stock >= cp.quantity; -- 사용자 1 장바구니의 선택된 상품, 재고 가능한것만
	
	
	-- 전 쿼리에서 생성 수, 0일때(재고부족으로 주문할 상품이 없을때) 재고부족 메세지
	SET count_o := ROW_COUNT();
	
	IF count_o = 0 THEN
		ROLLBACK;
		signal sqlstate '45000' SET MESSAGE_TEXT = '재고부족 또는 장바구니 상품 없음';
	END IF;
			
	-- 재고 차감
	UPDATE products p
	JOIN order_products op ON op.product_id = p.product_id 
	SET p.stock = p.stock - op.quantity
	WHERE op.order_id = p_order; 

	-- 주문완료된 건은 카트에서 삭제
	DELETE cp FROM cart_products cp
	JOIN order_products op ON op.product_id = cp.product_id AND op.order_id = p_order
	WHERE cp.user_id = p_user_id AND cp.is_selected =1;

	COMMIT;
END//

DELIMITER ;

-- DROP PROCEDURE create_order_cart;


-- ===============================================================
SET @order = 0;

CALL create_order_cart(4, '두두솜', '01063145555', '서울시 어쩌구 저쩌구', @order);

SELECT @order AS 생성주문;

-- ===================================================================


-- 상태 전환
UPDATE orders
SET status = '배송중' -- 배송완료도 같은 방식
WHERE order_id = 1; -- 주문 아이디 1

-- 배송 상태 조회
SELECT status AS 배송상태
FROM orders 
WHERE order_id = 31; -- 주문 아이디 31

-- 주문 정보 조회
SELECT o.status AS 배송상태, o.receiver AS '받는 사람', o.phone_number AS 전화번호,o.address AS 주소, o.delivered_at AS 배송예정일,sum(op.price) AS 합계
FROM orders o
JOIN order_products op ON o.order_id = op.order_id 
WHERE user_id = 1 -- 하나의 유저에 대한 주문 목록, user_id 1의 예시
GROUP BY op.order_id 
ORDER BY o.created_at desc;

-- 결제 상품 목록 조회
SELECT p.name AS 품명, op.quantity AS 수량, op.price AS 가격
FROM order_products op
JOIN products p ON op.product_id = p.product_id 
WHERE order_id = 1; -- 하나의 주문에 대한 상품 목록, order_id 1의 예시

-- 반품 요청
INSERT INTO return_requests (order_product_id, comment, return_status)
SELECT op.order_product_id, '잘못 배송이 왔어요', '반품요청'
FROM order_products op
JOIN orders o ON o.order_id = op.order_id
WHERE op.order_product_id = 1 -- 주문 상품 아이디 1
  AND o.user_id = 1 -- 유저 아이디 1
  AND o.status = '배송완료';

 -- 반품 승인/완료
UPDATE return_requests 
SET return_status = '반품승인' -- 반품승인/반품완료
WHERE return_id = 6; -- 반품요청 아이디 6

-- 반품 완료 및 재고 복구
UPDATE products p
JOIN order_products op ON op.product_id = p.product_id
JOIN return_requests rr ON rr.order_product_id = op.order_product_id
SET p.stock = p.stock + op.quantity
WHERE rr.return_id = 6 AND rr.return_status = '반품완료';


-- 취소 요청
INSERT INTO withdraw_requests (order_id, comment, withdraw_status)
SELECT o.order_id, '다른 상품이랑 같이 구매할게요', '취소요청'
FROM orders o
WHERE o.order_id = 37 -- 주문 아이디 1
  AND o.status = '출고전';

  -- 취소완료
  UPDATE withdraw_requests
  SET withdraw_status = '취소완료'
  WHERE order_id = 37;
  
-- 취소 완료 후 트리거 ===================================================
DELIMITER //

CREATE TRIGGER complete_withdraw
	AFTER UPDATE
	ON withdraw_requests
	FOR EACH ROW 
BEGIN
	IF NEW.withdraw_status != OLD.withdraw_status THEN
		IF NEW.withdraw_status = '취소완료' THEN 
 			 -- 재고 복구
  			UPDATE products p 
 			JOIN order_products op ON op.product_id = p.product_id
  			SET p.stock = p.stock + op.quantity
  			WHERE op.order_id = new.order_id;


  			UPDATE orders
  			SET status = '취소완료'
  			WHERE order_id = NEW.order_id;
  		END if;
  	END if;
END//

DELIMITER ;
================================================================

-- DROP trigger complete_withdraw;

-- 반품/취소 진행상태 조회
SELECT return_status AS 진행상태
FROM return_requests 
WHERE return_id = 6 -- 주문 아이디 31
ORDER BY created_at DESC;



