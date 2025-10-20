CREATE TABLE symptoms(
  symptom_id BIGINT AUTO_INCREMENT,
  symptom_name varchar(30) NOT NULL,
  PRIMARY KEY(symptom_id)
);

CREATE TABLE user_symptoms(
  user_id BIGINT,
  symptom_id BIGINT,
  PRIMARY key(user_id, symptom_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (symptom_id) REFERENCES symptoms(symptom_id)
);

CREATE TABLE product_symptoms(
  product_symptom_id BIGINT AUTO_INCREMENT,
  product_id BIGINT,
  symptom_id BIGINT,
  PRIMARY key(product_symptom_id),
  FOREIGN KEY(product_id) REFERENCES products(product_id),
  FOREIGN key(symptom_id) REFERENCES symptoms(symptom_id)
);

CREATE TABLE product_reviews(
  product_review_id BIGINT AUTO_INCREMENT,
  user_id BIGINT,
  product_id BIGINT,
  title varchar(20) NOT NULL,
  content varchar(1000) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(product_review_id),
  FOREIGN KEY(user_id) REFERENCES users(user_id),
  FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE product_messages(
  product_message_id BIGINT AUTO_INCREMENT,
  product_review_id BIGINT,
  user_id BIGINT,
  review_type VARCHAR(10) CHECK (review_type IN ('like','dislike')),
  content VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(product_message_id),
  FOREIGN KEY (product_review_id) REFERENCES product_reviews(product_review_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) 
);