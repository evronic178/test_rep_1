explain analyze
SELECT COUNT(*) FROM (SELECT DISTINCT RES.ID_ 
       
  
      from ACT_ID_USER RES 
       
        inner join ACT_ID_MEMBERSHIP M on RES.ID_ = M.USER_ID_
        inner join ACT_ID_GROUP G on M.GROUP_ID_ = G.ID_
       
       
      
       
           
      
      
       WHERE  G.ID_ = camunda-admin
     
      ) countDistinct



explain analyze
 SELECT r.SPECIFIC_CATALOG, r.SPECIFIC_SCHEMA, r.SPECIFIC_NAME, r.DATA_TYPE
    FROM INFORMATION_SCHEMA.ROUTINES r
      LEFT JOIN pg_catalog.pg_namespace n ON r.ROUTINE_SCHEMA = n.nspname
      LEFT JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid AND r.SPECIFIC_NAME = p.proname || '_' || p.oid
      LEFT JOIN (SELECT SPECIFIC_SCHEMA, SPECIFIC_NAME, COUNT(*)as cnt FROM INFORMATION_SCHEMA.parameters WHERE parameter_mode IN('OUT', 'INOUT') GROUP BY SPECIFIC_SCHEMA, SPECIFIC_NAME) as outp
        ON r.SPECIFIC_SCHEMA = outp.SPECIFIC_SCHEMA AND r.SPECIFIC_NAME = outp.SPECIFIC_NAME
    WHERE r.DATA_TYPE <> 'record' AND r.DATA_TYPE <> 'void' AND p.proretset = false AND (outp.cnt IS NULL OR outp.cnt = 0)




explain analyze
 SELECT i."BoTemplateImmutableId" AS "TemplateId", MAX(i."EditDate") AS "EditDate"
  FROM "Instances" AS i
  WHERE i."BoTemplateImmutableId" = ANY ({e28b45e7-5b4c-47da-b41a-a2d9036472b5,fc2d3b40-d652-4d8a-9558-0b3f4dc09a54,75df89b1-a3ce-494f-9d61-27b643e5b510,8f533f58-8460-427f-9c6d-fde55209bdfe,838e151c-3aa4-4d90-a410-2b8998af36af,a62c87d7-11ec-478e-959d-8ef587712d46,38971840-1132-4f63-98fc-fb3eba708de1,c84ade40-5394-469c-99b0-eddcc2b40201,c403aefb-41eb-4dab-a6d9-a60d5abebcc2,a91e057a-2d4d-49ad-bc4f-7e472a868fd5,8751865b-af16-4b89-9718-5a8a3cc73b46,a5a50f04-4202-4901-88d0-1e0a6076a650,4e20649b-c63e-46e2-9c23-d90ea225c2cd,7dd72933-bd28-46ad-87a8-22aa51b0bf7d,a0042a3d-3fc8-4978-b6d8-c541d2665eb6,a079e94c-fd61-4c07-a1ce-f45180782e10,6a7d0e2b-4685-4e2e-9684-1db076102d18,cf30f4c4-0de1-48e9-a528-c6eb8d668d2d,f7e74b1e-75e7-4341-9055-1e30ed7721f7,c7996d52-65b5-402b-b6e2-1a7e44ce1e74,c89337ae-607d-4b6e-8384-5b0a5bb01336,17307506-880f-46e1-91ee-9c0131e7c63b,d7a570c9-f0b5-463f-a37e-105a8f0bac3a,71a5d76a-0bbc-41b8-9684-7208999076b9,61cc3fbb-210a-4e9b-af59-6461027257b4,35498ebe-4b1a-40b5-94ef-cad02919a8f0,8662a0c9-4fa9-45ef-beb2-a9a3d40ac8d2,ba2b4ed6-021a-42b2-82cc-07116f1ef796,159db7de-c6be-455b-8a64-236b9620acfa,713be1bd-78f8-4132-b3be-c0b296507cd3,b8a56cae-f4c5-44bc-8b7a-5ff108bd6a2f,a300e515-61b0-4c6c-a6a1-58a71f573920}') OR (((i."BoTemplateImmutableId" IS NULL)) AND ((array_position({e28b45e7-5b4c-47da-b41a-a2d9036472b5,fc2d3b40-d652-4d8a-9558-0b3f4dc09a54,75df89b1-a3ce-494f-9d61-27b643e5b510,8f533f58-8460-427f-9c6d-fde55209bdfe,838e151c-3aa4-4d90-a410-2b8998af36af,a62c87d7-11ec-478e-959d-8ef587712d46,38971840-1132-4f63-98fc-fb3eba708de1,c84ade40-5394-469c-99b0-eddcc2b40201,c403aefb-41eb-4dab-a6d9-a60d5abebcc2,a91e057a-2d4d-49ad-bc4f-7e472a868fd5,8751865b-af16-4b89-9718-5a8a3cc73b46,a5a50f04-4202-4901-88d0-1e0a6076a650,4e20649b-c63e-46e2-9c23-d90ea225c2cd,7dd72933-bd28-46ad-87a8-22aa51b0bf7d,a0042a3d-3fc8-4978-b6d8-c541d2665eb6,a079e94c-fd61-4c07-a1ce-f45180782e10,6a7d0e2b-4685-4e2e-9684-1db076102d18,cf30f4c4-0de1-48e9-a528-c6eb8d668d2d,f7e74b1e-75e7-4341-9055-1e30ed7721f7,c7996d52-65b5-402b-b6e2-1a7e44ce1e74,c89337ae-607d-4b6e-8384-5b0a5bb01336,17307506-880f-46e1-91ee-9c0131e7c63b,d7a570c9-f0b5-463f-a37e-105a8f0bac3a,71a5d76a-0bbc-41b8-9684-7208999076b9,61cc3fbb-210a-4e9b-af59-6461027257b4,35498ebe-4b1a-40b5-94ef-cad02919a8f0,8662a0c9-4fa9-45ef-beb2-a9a3d40ac8d2,ba2b4ed6-021a-42b2-82cc-07116f1ef796,159db7de-c6be-455b-8a64-236b9620acfa,713be1bd-78f8-4132-b3be-c0b296507cd3,b8a56cae-f4c5-44bc-8b7a-5ff108bd6a2f,a300e515-61b0-4c6c-a6a1-58a71f573920}', NULL) IS NOT NULL)))
  GROUP BY i."BoTemplateImmutableId"
  HAVING i."BoTemplateImmutableId" = '713be1bd-78f8-4132-b3be-c0b296507cd3'
  LIMIT 1
