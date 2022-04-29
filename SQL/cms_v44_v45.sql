//*********************
//Created: 2020-11-25 By: Kovalev
//What: CMS DB Upgrade, DB version 45
// - Tables upgrade      
//*********************
create variable DBVER integer;

select "dbversion" into DBVER from "dba"."globattrs";

IF DBVER = 44 THEN
  ALTER TABLE "dba"."GlobAttrs" 
  ADD "DCMPath" varchar(255) NULL
END IF;

IF DBVER = 44 THEN
  CREATE TABLE "dba"."DCMComQueue" ( 
	"DCMCQID" INTEGER not null DEFAULT autoincrement,
	"DCMCQDT" DATETIME,
	"DCMCQSID" INTEGER,
        "DCMCQIUID" varchar(65) NULL,
        "DCMCQCUID" varchar(65) NULL,
        "DCMCQTUID" varchar(65) NULL,
        PRIMARY KEY ("DCMCQID") ) 
END IF;

UPDATE "dba"."GlobAttrs"
  SET "dbversion" = 45  
WHERE "globattrs"."dbversion" = 44;

drop variable DBVER;

commit;

DROP PROCEDURE IF EXISTS "DBA"."cms_RebuildDCMComQueueTable";

CREATE PROCEDURE "DBA"."cms_RebuildDCMComQueueTable"( out @RebuildFlag integer )
 //*********************
 //Added: 2020-11-25 By: Kovalev
 //
 //*********************
BEGIN
  SET @RebuildFlag = 0;
  IF not EXISTS (SELECT 1 FROM "dba"."DCMComQueue" ) THEN
    DROP TABLE "dba"."DCMComQueue";
    CREATE TABLE "dba"."DCMComQueue"(
	"DCMCQID" INTEGER not null DEFAULT autoincrement,
	"DCMCQDT" DATETIME,
 	"DCMCQSID" INTEGER,
        "DCMCQIUID" varchar(65) NULL,
        "DCMCQCUID" varchar(65) NULL,
        "DCMCQTUID" varchar(65) NULL,
        PRIMARY KEY ("DCMCQID") ); 
    SET @RebuildFlag = 1;
  END IF;
END;

DROP PROCEDURE IF EXISTS "DBA"."cms_AddToDCMComQueueTable";

CREATE PROCEDURE "DBA"."cms_AddToDCMComQueueTable"( in @ASecTimeShift integer, @ASID integer, in @AInstUID long varchar, in @AClassUID long varchar, out @AddFlag integer )
 //*********************
 //Added: 2020-11-25 By: Kovalev
 //
 //*********************
BEGIN
  SET @AddFlag = 0;
  IF not EXISTS (SELECT 1 FROM "dba"."DCMComQueue" where "DCMCQIUID" = @AInstUID ) THEN
    INSERT INTO "dba"."DCMComQueue" ( "DCMCQDT", "DCMCQSID", "DCMCQIUID", "DCMCQCUID" ) VALUES ( DATEADD(second, @ASecTimeShift, GETDATE() ), @ASID, @AInstUID, @AClassUID );
    SET @AddFlag = 1;
  END IF;
END;

