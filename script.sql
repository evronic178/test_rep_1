explain analyze
SELECT COUNT(*) FROM (SELECT DISTINCT RES.ID_ 
       
  
      from ACT_ID_USER RES 
       
        inner join ACT_ID_MEMBERSHIP M on RES.ID_ = M.USER_ID_
        inner join ACT_ID_GROUP G on M.GROUP_ID_ = G.ID_
       
       
      
       
           
      
      
       WHERE  G.ID_ = camunda-admin
     
      ) countDistinct
