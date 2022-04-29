//*********************
//Created: 2021-01-04 By: Kovalev
//What: CMS DB Upgrade, DB version 45
// - Tables upgrade      
//*********************
create variable DBVER integer;

select "dbversion" into DBVER from "dba"."globattrs";

IF DBVER = 45 THEN
  CREATE TABLE "dba"."DCMRQueue" ( 
	"DCMRQID" INTEGER not null DEFAULT autoincrement,
        "DCMRQCMSPID" INTEGER not null,
        "DCMRQDCMPID" varchar(65) NULL,
        "DCMRQSTUID" varchar(65) NULL,
        "DCMRQSEUID" varchar(65) NULL,
        PRIMARY KEY ("DCMRQID") ) 
END IF;

IF DBVER = 45 THEN
  ALTER TABLE "dba"."AllSlides"
  ADD "DCMSerID" integer NULL
END IF;

UPDATE "dba"."GlobAttrs"
  SET "dbversion" = 46  
WHERE "globattrs"."dbversion" = 45;

drop variable DBVER;

commit;

DROP PROCEDURE IF EXISTS "DBA"."cms_RebuildDCMRQueueTable";

CREATE PROCEDURE "DBA"."cms_RebuildDCMRQueueTable"( out @RebuildFlag integer )
 //*********************
 //Added: 2021-01-04 By: Kovalev
 //
 //*********************
BEGIN
  SET @RebuildFlag = 0;
  IF not EXISTS (SELECT 1 FROM "dba"."DCMRQueue" ) THEN
    DROP TABLE "dba"."DCMRQueue";
    CREATE TABLE "dba"."DCMRQueue"(
	"DCMRQID" INTEGER not null DEFAULT autoincrement,
        "DCMRQCMSPID" INTEGER not null,
        "DCMRQDCMPID" varchar(65) NULL,
        "DCMRQSTUID" varchar(65) NULL,
        "DCMRQSEUID" varchar(65) NULL,
        PRIMARY KEY ("DCMRQID") ); 
    SET @RebuildFlag = 1;
  END IF;
END;



