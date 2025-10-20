SELECT 
            p.name , p.thumbnail_img, 
                                                                           
            MAX(CASE WHEN p.gender = ud.gender_code OR p.gender ='B' THEN 1 ELSE 0 end)
          + MAX(CASE WHEN ud.age_code BETWEEN p.min_age AND p.max_age THEN 1 ELSE 0 end)
          + count(DISTINCT CASE 
                       WHEN ps.symptom_id = us.symptom_id THEN ps.symptom_id
                       END                                                                              

                  ) AS total_score

FROM user_details ud

JOIN user_symptoms us ON ud.user_id = us.user_id
JOIN product_symptoms ps ON us.symptom_id = ps.symptom_id 
JOIN products p ON ps.product_id = p.product_id

WHERE ud.user_id = (?)


GROUP BY 
          p.product_id , p.name 
ORDER BY  total_score DESC 
                     LIMIT 5;
                  
