﻿  /*
  AUTHOR: AMIT KUMAR SINGH
  PROJECT: PHOENIX
  CREATION DATE: 02-JUL-2015
  DESCRIPTION: THIS SQL CODE IS USED TO CREATE X02 FILE SPLIT OBJECTS (TABLES/SPS/FUNCTIONS)
  (
  TB_UDMH_X03GT1_ROW_COUNT,
  TB_UDMH_X02_SPLIT,
  TB_UDMH_X02_DISCARD,
  TB_UDMH_X03_SPLIT,
  SPLIT,
  PR_UDMH_INSERT_X02_SPLIT,
  PR_UDMH_INSERT_X02_DISCARD,
  PR_UDMH_INSERT_X03_SPLIT,
  PR_UDMH_INSERT_X03_DISCARD,
  PR_UDMH_X02FT1_SPLIT_ROW_COUNTS,
  PR_UDMH_X03FT1_SPLIT_ROW_COUNTS,
  PR_UDMH_X02_ACCOUNT_SPLIT,
  PR_UDMH_X03_ACCOUNT_SPLIT,
  dbo.PR_X02_FT1_UPDATE
  PR_X02_SPLIT_GEN
  )
  REVISION HISTORY:
 -----------------------------------------------------------------------------------------------------
  VERSION    	DATE        	DEVELOPER         		DESCRIPTION
 -----------------------------------------------------------------------------------------------------
    1.0         02-JUL-2015		AMIT					INITIAL DRAFT   
	2.0			21-AUG-2015		AMIT					X03 IS NOT APPLICABLE FOR PHOENIX. COMMENTED X03 RELATED OBJECTS 
 -----------------------------------------------------------------------------------------------------
*/



--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[TB_UDMH_X03GT1_ROW_COUNT]') AND TYPE IN (N'U'))
--DROP TABLE [DBO].[TB_UDMH_X03GT1_ROW_COUNT]
--GO
--CREATE TABLE [DBO].[TB_UDMH_X03GT1_ROW_COUNT]
--(
--	[X03_KEY] [CHAR](16) NOT NULL,
--	[RECORDTYPE] [CHAR](7) NULL,
--	[X03_CHUNK_NUM] [CHAR](2) NOT NULL,
--	[SORDER] [CHAR](3) NULL,
--	[DATACOLUMN] [VARCHAR](2011) NULL
--) 
--GO

--For creating table TB_UDMH_X02_SPLIT
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[TB_UDMH_X02_SPLIT]') AND TYPE IN (N'U'))
DROP TABLE [DBO].[TB_UDMH_X02_SPLIT]
GO
CREATE TABLE [dbo].[TB_UDMH_X02_SPLIT](
	[X02KEY] [char](16) NULL,
	[RECORDTYPE] [char](7) NULL,
	[SORDER] [char](3) NULL,
	[GROUP_RANK] [bigint] NULL,
	[DATACOLUMN] [varchar](2000) NULL
) ON [PRIMARY]

GO
--For creating table TB_UDMH_X02_DISCARD
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[TB_UDMH_X02_DISCARD]') AND TYPE IN (N'U'))
DROP TABLE [DBO].[TB_UDMH_X02_DISCARD]
GO
CREATE TABLE [dbo].[TB_UDMH_X02_DISCARD](
	[X02KEY] [char](16) NULL,
	[RECORDTYPE] [char](7) NULL
) ON [PRIMARY]

GO

--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[TB_UDMH_X03_SPLIT]') AND TYPE IN (N'U'))
--DROP TABLE [DBO].[TB_UDMH_X03_SPLIT]
--GO
--CREATE TABLE [DBO].[TB_UDMH_X03_SPLIT]
--(
--	[X03KEY] [CHAR](16) NULL,
--	[RECORDTYPE] [CHAR](7) NULL,
--	[X03-CHUNK-NUM] [CHAR](2) NULL,
--	[SORDER] [CHAR](3) NULL,
--	[GROUP_RANK] [BIGINT] NULL,
--	[DATACOLUMN] [VARCHAR](2000) NULL
--)
--GO

--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[TB_UDMH_X03_DISCARD]') AND TYPE IN (N'U'))
--DROP TABLE [DBO].[TB_UDMH_X03_DISCARD]
--GO
--CREATE TABLE [DBO].[TB_UDMH_X03_DISCARD](
--	[X03KEY] [CHAR](16) NULL,
--	[RECORDTYPE] [CHAR](7) NULL,
--	[X03-CHUNK-NUM] [CHAR](2) NULL,
--	[SORDER] [CHAR](3) NULL,
--	[DATACOLUMN] [CHAR](2000) NULL
--) 
--GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PR_X02_SPLIT_GEN') AND type in (N'P',N'PC'))
DROP PROCEDURE dbo.PR_X02_SPLIT_GEN   
GO  

CREATE PROCEDURE dbo.PR_X02_SPLIT_GEN 
(
  @START_AT INT,
  @END_AT INT
)
AS
SET NOCOUNT ON;    
BEGIN    
SELECT DATACOLUMN 
  FROM TB_UDMH_X02_SPLIT 
 WHERE GROUP_RANK BETWEEN @START_AT AND @END_AT
 ORDER BY (X02KEY + SORDER + 
        COALESCE(CASE RECORDTYPE
        --X02-A01-SEQNO
        WHEN 'X02_A01' THEN SUBSTRING(DATACOLUMN,4,2)  
		
        --X02-A02-SUB-ACC then X02-A02-START-ARR-DT 
        WHEN 'X02_A02' THEN SUBSTRING(DATACOLUMN,4,2)+ SUBSTRING(DATACOLUMN,187,8) --Fixed 29074
        
		--X02-A05-POSTED-DT then SK-MOR97-rec_nbr_o(Filler) then SK-MOR97-accnbr_o(Filler)
        WHEN 'X02_A05' THEN SUBSTRING(DATACOLUMN,57,8)+ SUBSTRING(DATACOLUMN,497,10)+ SUBSTRING(DATACOLUMN,507,10)
        
		--X02-A06-SUB-ACC then X02-A06-EFFECT-DT
        WHEN 'X02_A06' THEN SUBSTRING(DATACOLUMN,4,2) + SUBSTRING(DATACOLUMN,6,8) 
        
		--X02-A07-POSTED-DT then arrears then T-Amount
        WHEN 'X02_A07' THEN SUBSTRING(DATACOLUMN,22,8)+ CASE SUBSTRING(DATACOLUMN,30,1) WHEN '-' THEN '*' ELSE '+' END + SUBSTRING(DATACOLUMN,12,10) + SUBSTRING(DATACOLUMN,31,10)  
        
		--X02-MAR08.UFS-SUB-NO then X02-A16-EFFECT-DT 
        WHEN 'X02_A16' THEN SUBSTRING(DATACOLUMN,220,2)+ SUBSTRING(DATACOLUMN,78,8)
        
		--X02-C01-SEQNO
		WHEN 'X02_C01' THEN SUBSTRING(DATACOLUMN,4,1)+RECORDTYPE
		
		--X02-CUS02.C03-ACC-LINK
        WHEN 'X02_C03' THEN
              CASE
				WHEN SUBSTRING(DATACOLUMN,5,1) <= '4' THEN SUBSTRING(DATACOLUMN,5,1)
              ELSE
              CAST(
                   CAST(SUBSTRING(DATACOLUMN,5,1) AS INT)
                   - 4
                   + MAX(CASE WHEN RECORDTYPE = 'X02_C03' AND CAST(SUBSTRING(DATACOLUMN,5,1) AS INT) <= 4  
                              THEN CAST(SUBSTRING(DATACOLUMN,5,1) AS INT) 
                          END) OVER (
					   PARTITION BY 
					     X02KEY
					   ) AS VARCHAR(1))
         END+RECORDTYPE 
						  
		--X02-F01-SUB-ACC 
        WHEN 'X02_F01' THEN SUBSTRING(DATACOLUMN,4,2) 
        
		--X02-F05-EFF-DT 
        WHEN 'X02_F05' THEN SUBSTRING(DATACOLUMN,32,8)
        
		--X02-F07-SUB-ACC then X02-F07-START-DT
        WHEN 'X02_F07' THEN SUBSTRING(DATACOLUMN,4,2) + SUBSTRING(DATACOLUMN,68,8) 
        
		--X02-I01-SUB-ACC then FOC='YES' then X02-I01-CUR-DT
        WHEN 'X02_I01' THEN SUBSTRING(DATACOLUMN,4,2)
                          + CASE WHEN SUBSTRING(DATACOLUMN,21,3) ='FOC' 
                                 THEN '1' 
                                 ELSE '2' 
                             END 
                          + SUBSTRING(DATACOLUMN,149,8)
        
		--X02-I03-SUB-ACC then X02-I03-POL-DT
        WHEN 'X02_I03' THEN SUBSTRING(DATACOLUMN,4,2) + SUBSTRING(DATACOLUMN,205,8) 
        
		--C01_LINK_NUM(Filler)                          
        WHEN 'X02_L01' THEN SUBSTRING(DATACOLUMN,635,2) 
        
		--X03-M07-CREATE-DT then M07-NOTE-TYPE then M07-PAGE-NO
        WHEN 'X02_M07' THEN SUBSTRING(DATACOLUMN,4,8)+SUBSTRING(DATACOLUMN,12,9)+SUBSTRING(DATACOLUMN,21,4) 		
		
		--M14-VTR-UNIQID
        WHEN 'X02_M14' THEN SUBSTRING(DATACOLUMN,6,40) 
        
		--X02-MA5-RECV-DT
        WHEN 'X02_MA5' THEN SUBSTRING(DATACOLUMN,150,8) 
        
		--MA6- SUB-NO then X02-MA6-POSTED-RDN
        WHEN 'X02_MA6' THEN SUBSTRING(DATACOLUMN,67,2) + SUBSTRING(DATACOLUMN,55,8)
        
		--X02-P01-SEQNO
        WHEN 'X02_P01' THEN SUBSTRING(DATACOLUMN,4,2)
        
		--X02-P04-VALRCV-DT 
        WHEN 'X02_P04' THEN SUBSTRING(DATACOLUMN,57,8) 
        
		--S03-RANK-NBR
        WHEN 'X02_S03' THEN SUBSTRING(DATACOLUMN,235,3) 
        
        ELSE ''       
     END,''))
END;    


GO

IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_INSERT_X02_SPLIT]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [DBO].[PR_UDMH_INSERT_X02_SPLIT]
GO
CREATE PROCEDURE [DBO].[PR_UDMH_INSERT_X02_SPLIT] 
AS
SET ANSI_WARNINGS OFF ;

BEGIN
SET NOCOUNT ON;

TRUNCATE TABLE [TB_UDMH_X02_SPLIT]
;   
INSERT INTO TB_UDMH_X02_SPLIT 
SELECT LTRIM(RTRIM(X02.X02KEY)) AS X02KEY
      ,LTRIM(RTRIM(RECORDTYPE)) AS RECORDTYPE
      ,LTRIM(RTRIM(SORDER)) AS SORDER
      ,CAST(DENSE_RANK()OVER (
              ORDER BY 
                X02.X02KEY
              ) AS BIGINT
           ) AS GROUP_RANK
      ,DATACOLUMN
  FROM TB_UDMH_X02 X02
 WHERE X02.X02KEY IN
       (SELECT X02KEY 
          FROM TB_UDMH_MORT_ACCOUNT)
 ORDER BY 
   X02KEY
  ,SORDER
END;

GO

IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_INSERT_X02_DISCARD]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [DBO].[PR_UDMH_INSERT_X02_DISCARD]
GO
CREATE PROCEDURE [dbo].[PR_UDMH_INSERT_X02_DISCARD]  
--@GROUPCOUNT INT OUTPUT 
AS
SET ANSI_WARNINGS OFF ;
BEGIN
SET NOCOUNT ON;
TRUNCATE TABLE TB_UDMH_X02_DISCARD

SELECT 
	LTRIM(RTRIM(X02KEY)) AS X02KEY,
	LTRIM(RTRIM([RECORDTYPE])) AS [RECORDTYPE]
FROM TB_UDMH_X02
WHERE X02KEY NOT IN(
	SELECT X02KEY
	FROM TB_UDMH_X02
	WHERE RECORDTYPE ='X02_GH1' )
	
END;
GO

--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_INSERT_X03_SPLIT]') AND TYPE IN (N'P', N'PC'))
--DROP PROCEDURE [DBO].[PR_UDMH_INSERT_X03_SPLIT]
--GO
--CREATE PROCEDURE [DBO].[PR_UDMH_INSERT_X03_SPLIT]  
--AS
--BEGIN
--SET NOCOUNT ON;
--TRUNCATE TABLE TB_UDMH_X03_SPLIT
--;
--SELECT 
--     LTRIM(RTRIM(X03.X03KEY))  AS X03KEY
--	,LTRIM(RTRIM([RECORDTYPE])) AS [RECORDTYPE]
--	,LTRIM(RTRIM([X03-CHUNK-NUM])) AS [X03-CHUNK-NUM]
--	,LTRIM(RTRIM([SORDER])) AS [SORDER]
--	,[DATACOLUMN]
--	,DENSE_RANK()OVER (ORDER BY X03.X03KEY) AS [GROUP_RANK]
--FROM TB_UDMH_X03 X03
-- WHERE X03KEY IN (
--                SELECT X03KEY FROM TB_UDMH_INV_ACCOUNT)    
--ORDER BY X03.X03KEY, SORDER
--END;

--GO

--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_INSERT_X03_DISCARD]') AND TYPE IN (N'P', N'PC'))
--DROP PROCEDURE [DBO].[PR_UDMH_INSERT_X03_DISCARD]
--GO
--CREATE PROCEDURE [DBO].[PR_UDMH_INSERT_X03_DISCARD]  
--AS
--SET ANSI_WARNINGS OFF ;
--BEGIN
--SET NOCOUNT ON;
--TRUNCATE TABLE TB_UDMH_X03_DISCARD

--SELECT 
--	LTRIM(RTRIM(X03KEY)) AS X03KEY,
--	LTRIM(RTRIM([RECORDTYPE])) AS [RECORDTYPE],
--	LTRIM(RTRIM([X03-CHUNK-NUM])) AS [X03-CHUNK-NUM],
--	LTRIM(RTRIM([SORDER])) AS [SORDER],
--	[DATACOLUMN]
--FROM TB_UDMH_X03
--WHERE X03KEY NOT IN(
--	SELECT X03KEY
--	FROM TB_UDMH_X03
--	WHERE RECORDTYPE ='X03_GH1' )
--END;

--GO

IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_X02FT1_SPLIT_ROW_COUNTS]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [DBO].[PR_UDMH_X02FT1_SPLIT_ROW_COUNTS]
GO
CREATE PROCEDURE [DBO].[PR_UDMH_X02FT1_SPLIT_ROW_COUNTS]   
  (@START_AT INT,
   @END_AT INT
   --@FT1DATACOLUMN VARCHAR(2000) OUTPUT
   )
   AS
 SET NOCOUNT ON;    
 DECLARE @CHUNKNUMBER AS VARCHAR(2) ='01'  
 BEGIN    
     
 DECLARE @ROW_COUNT NUMERIC(10,0) ;    -- TO HOLD ROW COUNTS ALL BARROWERS ACCOUNT(SOURCE-ID) IN X02 TABLE    
 DECLARE @DATACOLUMN VARCHAR(2000);   -- TO HOLD "DATACOLUMN" COLUMN OF X02 TABLE.    
 DECLARE @FT1_TOTADV NUMERIC (14,0) ; -- TO HOLD SUM OF [GT1-TOTADV] COLUMN OF ALL BARROWERS ACCOUNTS -- AG CHANGED FROM (12,0) TO (14,0)    
 DECLARE @FT1_TOTIBB NUMERIC (20,2) ; -- AG CHANGED FROM (12,2) TO (20,2)    
 DECLARE @FT1_TOTCUR NUMERIC (20,2) ; -- AG CHANGED FROM (12,2) TO (20,2)    
 DECLARE @FT1_TOTCOV NUMERIC (20,0) ; -- AG CHANGED FROM (12,0) TO (20,0)    
 DECLARE @GT1_SIGN1 CHAR(1) ;   -- TO HOLD SIGN FOR  FT1_TOTIBB COLUMN    
 DECLARE @GT1_SIGN2 CHAR(1) ;   -- TO HOLD SIGN FOR  FT1_TOTCUR COLUMN    
     
 DECLARE @FT1_TOTIBB_CHAR CHAR(15);    
 DECLARE @FT1_TOTCUR_CHAR CHAR(15);    
      
SELECT  @ROW_COUNT  = SUM(CAST(SUBSTRING(DATACOLUMN,4,8) AS NUMERIC(10,0))) ,    
        @FT1_TOTADV = SUM(CAST(SUBSTRING( DATACOLUMN,12,8) AS  NUMERIC (14,0))) ,-- AG CHANGED FROM (12,0) TO (14,0)    
        @FT1_TOTIBB = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,20,11) AS FLOAT))/100 AS NUMERIC(20,2))) , -- AG CHANGED FROM (12,2) TO (20,2)    
        @FT1_TOTCUR = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,31,11) AS FLOAT))/100 AS NUMERIC(20,2) )) , -- AG CHANGED FROM (12,2) TO (20,2)
        @FT1_TOTCOV = SUM(CAST(SUBSTRING(DATACOLUMN,42,8) AS NUMERIC (20,0) ))  -- AG CHANGED FROM (12,2) TO (20,2)    
      
FROM DBO.TB_UDMH_X02_SPLIT  WITH(NOLOCK)    
WHERE RECORDTYPE ='X02_GT1' AND [GROUP_RANK] BETWEEN @START_AT AND @END_AT;    
       
   -- FIND OUT SIGNS FOR  FT1_TOTIBB &  FT1_TOTCUR    
       
   IF @FT1_TOTIBB >= 0     
     SET @GT1_SIGN1 = '+'    
   ELSE    
    SET @GT1_SIGN1 = '-';    
        
   IF @FT1_TOTCUR >= 0     
    SET @GT1_SIGN2 = '+'    
   ELSE    
    SET @GT1_SIGN2 = '-';     
        
   -- STORE THE ABSOLUTE VALUE OF  FT1_TOTIBB &  FT1_TOTCUR    
   -- AS WE ARE GOING TO STORE SIGN IN SEPERATE FIELD ( AS ABOVE)    
        
   SET @FT1_TOTIBB = ABS(@FT1_TOTIBB);           
   SET @FT1_TOTCUR = ABS(@FT1_TOTCUR);    
       
   SET @FT1_TOTIBB_CHAR = CAST(@FT1_TOTIBB AS CHAR(21)); 
   SET @FT1_TOTCUR_CHAR = CAST(@FT1_TOTCUR AS CHAR(21)); 
   
SELECT   
'FT1'+    
        RIGHT(REPLICATE('0',10) + CAST(@ROW_COUNT AS VARCHAR(10)) , 10)+    
        RIGHT(REPLICATE('0',12) + CAST(@FT1_TOTADV AS VARCHAR(12)) , 12)+    
        @GT1_SIGN1+    
        RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTIBB_CHAR,1,LEN(@FT1_TOTIBB_CHAR) -3)+ SUBSTRING(@FT1_TOTIBB_CHAR,LEN(@FT1_TOTIBB_CHAR)-1,LEN(@FT1_TOTIBB_CHAR))))) , 14)+    
        @GT1_SIGN2+    
        RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTCUR_CHAR,1,LEN(@FT1_TOTCUR_CHAR) -3)+ SUBSTRING(@FT1_TOTCUR_CHAR,LEN(@FT1_TOTCUR_CHAR)-1,LEN(@FT1_TOTCUR_CHAR))))) , 14)+    
        RIGHT(REPLICATE('0',12) + CAST(@FT1_TOTCOV AS VARCHAR(12)) , 12)    
         
END;
   
GO

--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_X03FT1_SPLIT_ROW_COUNTS]') AND TYPE IN (N'P', N'PC'))
--DROP PROCEDURE [DBO].[PR_UDMH_X03FT1_SPLIT_ROW_COUNTS]
--GO
--CREATE PROCEDURE [DBO].[PR_UDMH_X03FT1_SPLIT_ROW_COUNTS]   
--  (@START_AT INT,
--   @END_AT INT
--   --@FT1DATACOLUMN VARCHAR(2000) OUTPUT
--   )
--   AS
-- SET NOCOUNT ON;    
-- DECLARE @CHUNKNUMBER AS VARCHAR(2) ='01'  
-- BEGIN    
     
-- DECLARE @ROW_COUNT NUMERIC(10,0) ;    -- TO HOLD ROW COUNTS ALL BARROWERS ACCOUNT(SOURCE-ID) IN X03 TABLE      
-- DECLARE @DATACOLUMN VARCHAR(2000);   -- TO HOLD "DATACOLUMN" COLUMN OF X03 TABLE.      
-- DECLARE @FT1_TOTCUR NUMERIC (20,2) ; -- AG CHANGED FROM (12,2) TO (20,2)      
-- DECLARE @GT1_SIGN2 CHAR(1) ;   -- TO HOLD SIGN FOR  FT1_TOTCUR COLUMN      
       
-- --------- CHAR FIELDS      
-- DECLARE @FT1_TOTIBB_CHAR CHAR(15);      
-- DECLARE @FT1_TOTCUR_CHAR CHAR(15);     
      
--SELECT  @ROW_COUNT= SUM(CAST(SUBSTRING(DATACOLUMN, 4,10) AS NUMERIC(10,0))) ,      
--        @FT1_TOTCUR = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,15,14) AS FLOAT))/100 AS NUMERIC(20,2) ))-- AG CHANGED FROM (12,2) TO (20,2)   
     
--FROM DBO.TB_UDMH_X03_SPLIT  WITH(NOLOCK)    
--WHERE RECORDTYPE ='X03_GT1' AND [GROUP_RANK] BETWEEN @START_AT AND @END_AT
--   AND [X03-CHUNK-NUM]=@CHUNKNUMBER;    
       
--   -- FIND OUT SIGNS FOR  FT1_TOTIBB &  FT1_TOTCUR    
       
--   IF @FT1_TOTCUR >= 0       
--    SET @GT1_SIGN2 = '+'      
--   ELSE      
--    SET @GT1_SIGN2 = '-';     
        
--   -- STORE THE ABSOLUTE VALUE OF  FT1_TOTIBB &  FT1_TOTCUR    
--   -- AS WE ARE GOING TO STORE SIGN IN SEPERATE FIELD ( AS ABOVE)    
        
--   SET @FT1_TOTCUR = ABS(@FT1_TOTCUR);      
--  SET @FT1_TOTCUR_CHAR = CAST(@FT1_TOTCUR AS CHAR(21)); -- AG CHANGED FROM (15) TO (21)      
     
   
--SELECT   
--'FT1'+    
--       RIGHT(REPLICATE('0',10) + CAST(@ROW_COUNT AS VARCHAR(10)),10)+      
--        @GT1_SIGN2+      
--        RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTCUR_CHAR,1,LEN(@FT1_TOTCUR_CHAR) -3)+ SUBSTRING(@FT1_TOTCUR_CHAR,LEN(@FT1_TOTCUR_CHAR)-1,LEN(@FT1_TOTCUR_CHAR))))),14) 
--END;
    
--GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PR_UDMH_X02_ACCOUNT_SPLIT') AND type in (N'P',N'PC'))
DROP PROCEDURE dbo.PR_UDMH_X02_ACCOUNT_SPLIT   
GO 

CREATE PROCEDURE dbo.PR_UDMH_X02_ACCOUNT_SPLIT
(
   @M01_STATUS VARCHAR(10)
  ,@X02_CLOSUREDATE VARCHAR(8)
) 
AS
BEGIN
TRUNCATE TABLE TB_UDMH_MORT_ACCOUNT;

IF UPPER(@M01_STATUS) = 'NONE'
INSERT INTO TB_UDMH_MORT_ACCOUNT 
SELECT X02KEY 
  FROM TB_UDMH_X02 
 WHERE RECORDTYPE = 'X02_M01' 
   AND X02KEY IN (SELECT X02KEY 
                    FROM TB_UDMH_X02
                   WHERE RECORDTYPE ='X02_GH1' 
                     AND X02KEY NOT IN 
                         (SELECT EXCEPT_SRCFIELD_1 
                            FROM TB_UDMH_EXCEPTION 
                           WHERE EXCEPT_SEVERITY ='E'))

ELSE IF UPPER(@M01_STATUS) = 'CLOSED'
INSERT INTO TB_UDMH_MORT_ACCOUNT 
SELECT X02KEY 
  FROM TB_UDMH_X02 
 WHERE RECORDTYPE = 'X02_M01' 
   AND SUBSTRING(DATACOLUMN,150,1) = 'R'
   AND X02KEY IN (SELECT X02KEY 
                    FROM TB_UDMH_X02
                   WHERE RECORDTYPE ='X02_GH1' 
                     AND X02KEY NOT IN 
                         (SELECT EXCEPT_SRCFIELD_1 
                            FROM TB_UDMH_EXCEPTION 
                           WHERE EXCEPT_SEVERITY ='E'))

ELSE IF UPPER(@M01_STATUS) = 'OPEN'
INSERT INTO TB_UDMH_MORT_ACCOUNT 
SELECT X02KEY  
  FROM TB_UDMH_X02 
 WHERE RECORDTYPE = 'X02_M01' 
   AND SUBSTRING(DATACOLUMN,150,1) = 'L'
   AND X02KEY IN (SELECT X02KEY 
                    FROM TB_UDMH_X02
                   WHERE RECORDTYPE ='X02_GH1' 
                     AND X02KEY NOT IN 
                         (SELECT EXCEPT_SRCFIELD_1 
                            FROM TB_UDMH_EXCEPTION 
                           WHERE EXCEPT_SEVERITY ='E'))

--This is to fetch all records which have closure date greater than the specified configured date + All Live accounts
ELSE IF UPPER(@M01_STATUS) = 'ALL'
INSERT INTO TB_UDMH_MORT_ACCOUNT 
SELECT X02KEY 
  FROM TB_UDMH_X02 
 WHERE RECORDTYPE = 'X02_M01'
   AND (SUBSTRING(DATACOLUMN,150,1) = 'L' OR SUBSTRING(DATACOLUMN,330,8) >=@X02_CLOSUREDATE OR  
         (SELECT DISTINCT MAX(CONVERT(VARCHAR,X02_A01.A01_REDEEM_DT, 112)) OVER (
                            PARTITION BY 
                              X02KEY
                            )   
            FROM TB_X02_A01 X02_A01 
           WHERE X02_A01.X02KEY=TB_UDMH_X02.X02KEY)>= @X02_CLOSUREDATE
          ) 
   AND X02KEY IN (SELECT X02KEY 
                    FROM TB_UDMH_X02
                   WHERE RECORDTYPE ='X02_GH1' 
                     AND X02KEY NOT IN 
                         (SELECT EXCEPT_SRCFIELD_1 
                            FROM TB_UDMH_EXCEPTION 
                           WHERE EXCEPT_SEVERITY ='E'))
                             AND X02KEY NOT IN 
                                (SELECT BLK_X02_KEY 
                                   FROM TB_UDMH_BLACKLIST 
                                  CROSS JOIN TB_UDMH_CTL 
                                  WHERE SOURCE = BLK_SRC 
                                    AND BLK_FILE = 'X02')
                             
                             
ELSE IF UPPER(@M01_STATUS) = 'WHITELIST'
INSERT INTO TB_UDMH_MORT_ACCOUNT 
SELECT X02KEY 
  FROM TB_UDMH_X02 
 WHERE RECORDTYPE = 'X02_M01'
   AND (SUBSTRING(DATACOLUMN,150,1) = 'L' OR SUBSTRING(DATACOLUMN,330,8) >=@X02_CLOSUREDATE OR  
         (SELECT DISTINCT MAX(CONVERT(VARCHAR,A01_REDEEM_DT, 112)) OVER (
                            PARTITION BY 
                              X02KEY
                            )   
            FROM TB_X02_A01 X02_A01 
           WHERE X02_A01.X02KEY=TB_UDMH_X02.X02KEY)>= @X02_CLOSUREDATE
         ) 
   AND X02KEY IN 
       (SELECT X02KEY 
          FROM TB_UDMH_X02
         WHERE RECORDTYPE ='X02_GH1' 
           AND X02KEY NOT IN 
               (SELECT EXCEPT_SRCFIELD_1 
                  FROM TB_UDMH_EXCEPTION 
                 WHERE EXCEPT_SEVERITY ='E'))
           AND X02KEY IN 
              (SELECT WHT_X02_KEY 
                 FROM TB_UDMH_WHITELIST 
                CROSS JOIN TB_UDMH_CTL 
                WHERE SOURCE = WHT_SRC 
                  AND WHT_FILE = 'X02')

END

GO

--IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[PR_UDMH_X03_ACCOUNT_SPLIT]') AND TYPE IN (N'P', N'PC'))
--DROP PROCEDURE [DBO].[PR_UDMH_X03_ACCOUNT_SPLIT]
--GO
--CREATE PROCEDURE [DBO].[PR_UDMH_X03_ACCOUNT_SPLIT]
--(
--@A01_STATUS VARCHAR(10)
--,
--@X03_CLOSUREDATE VARCHAR(8)
--) AS
--BEGIN
--TRUNCATE TABLE TB_UDMH_INV_ACCOUNT;
--IF UPPER(@A01_STATUS) = 'CLOSED'
--INSERT INTO TB_UDMH_INV_ACCOUNT 
--		SELECT X03KEY FROM TB_UDMH_X03 WHERE RECORDTYPE = 'X03_A01' AND 
--                     SUBSTRING(DATACOLUMN,123,1) = 'C'
--                 AND X03KEY IN (SELECT X03KEY 
--	                            FROM TB_UDMH_X03
--	                            WHERE RECORDTYPE ='X03_GH1' AND [X03KEY] NOT IN 
--		                         (SELECT [EXCEPT_SRCKEY1] FROM TB_UDMH_EXCEPTION WHERE [EXCEPT_SEVERITY] ='E'))

--ELSE IF UPPER(@A01_STATUS) = 'OPEN'
--INSERT INTO TB_UDMH_INV_ACCOUNT 
--		SELECT X03KEY  FROM TB_UDMH_X03 WHERE RECORDTYPE = 'X03_A01' AND 
--                             SUBSTRING(DATACOLUMN,123,1) != 'C'
--                             AND X03KEY IN (SELECT X03KEY 
--	                            FROM TB_UDMH_X03
--	                            WHERE RECORDTYPE ='X03_GH1' AND [X03KEY] NOT IN 
--		                         (SELECT [EXCEPT_SRCKEY1] FROM TB_UDMH_EXCEPTION WHERE [EXCEPT_SEVERITY] ='E'))
----THIS IS TO FETCH ALL RECORDS WHICH HAVE CLOSURE DATE GREATER THAN THE SPECIFIED CONFIGURED DATE + ALL LIVE ACCOUNTS
--ELSE IF UPPER(@A01_STATUS) = 'ALL'
-- INSERT INTO TB_UDMH_INV_ACCOUNT 
--		SELECT X03KEY FROM TB_UDMH_X03 WHERE RECORDTYPE = 'X03_A01' AND 
--										(
--										SUBSTRING(DATACOLUMN,123,1) != 'C' OR
--										(SUBSTRING(DATACOLUMN,123,1) = 'C' AND SUBSTRING(DATACOLUMN,287,8)>=@X03_CLOSUREDATE)
--										)
--                              AND X03KEY IN (SELECT X03KEY 
--	                            FROM TB_UDMH_X03
--	                            WHERE RECORDTYPE ='X03_GH1' AND [X03KEY] NOT IN 
--		                         (SELECT [EXCEPT_SRCKEY1] FROM TB_UDMH_EXCEPTION WHERE [EXCEPT_SEVERITY] ='E'))
--		                      AND X03KEY NOT IN (SELECT BLK_X03X02_KEY FROM TB_UDMH_BLACKLIST CROSS JOIN TB_UDMH_CTL WHERE CON_SOCIETY = BLK_SOCIETY AND BLK_FILE = 'X03') -- FIXED #36816
		                  

--ELSE IF UPPER(@A01_STATUS) = 'WHITELIST'
-- INSERT INTO TB_UDMH_INV_ACCOUNT 
--		SELECT X03KEY FROM TB_UDMH_X03 WHERE RECORDTYPE = 'X03_A01' AND 
--										(
--										SUBSTRING(DATACOLUMN,123,1) != 'C' OR
--										(SUBSTRING(DATACOLUMN,123,1) = 'C' AND SUBSTRING(DATACOLUMN,287,8)>=@X03_CLOSUREDATE)
--										)
--                              AND X03KEY IN (SELECT X03KEY 
--	                            FROM TB_UDMH_X03
--	                            WHERE RECORDTYPE ='X03_GH1' AND [X03KEY] NOT IN 
--		                         (SELECT [EXCEPT_SRCKEY1] FROM TB_UDMH_EXCEPTION WHERE [EXCEPT_SEVERITY] ='E'))
--		                      AND X03KEY IN (SELECT WHT_X03X02_KEY FROM TB_UDMH_WHITELIST CROSS JOIN TB_UDMH_CTL WHERE CON_SOCIETY = WHT_SOCIETY AND WHT_FILE = 'X03')

--END

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PR_X02_FT1_UPDATE') AND type in (N'P',N'PC'))
DROP PROCEDURE dbo.PR_X02_FT1_UPDATE   
GO  
       
-- Create Procedure    
CREATE PROCEDURE dbo.PR_X02_FT1_UPDATE  
AS       
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
SET NOCOUNT ON;    
BEGIN    
    
--Need to UPDATE "FT1" Target type record with row counts     
--for ALL Account(SOURCE-ID).     
--So we need to update part of string in the "DATACOLUMN" column     
--of X02 table with row counts       
     
DECLARE @ROW_COUNT NUMERIC(10,0) ;    -- To hold ROW COUNTS all Account(SOURCE-ID) IN X02 Table    
DECLARE @DATACOLUMN VARCHAR(2000);   -- To hold "DATACOLUMN" column of X02 table.    
DECLARE @FT1_TOTADV NUMERIC (14,0) ; -- To hold sum of [GT1-TOTADV] column of all Accounts    
DECLARE @FT1_TOTIBB NUMERIC (20,2) ;    
DECLARE @FT1_TOTCUR NUMERIC (20,2) ;   
DECLARE @FT1_TOTCOV NUMERIC (20,0) ;   
DECLARE @GT1_SIGN1 CHAR(1) ;   -- To Hold sign for  FT1_TOTIBB column    
DECLARE @GT1_SIGN2 CHAR(1) ;   -- To Hold sign for  FT1_TOTCUR column    
     
--------- CHAR Fields   
 
DECLARE @FT1_TOTIBB_CHAR CHAR(15);    
DECLARE @FT1_TOTCUR_CHAR CHAR(15);    
      
SELECT @ROW_COUNT  = SUM(CAST(SUBSTRING(DATACOLUMN,4,8) AS NUMERIC(10,0)))    
      ,@FT1_TOTADV = SUM(CAST(SUBSTRING( DATACOLUMN,12,8) AS  NUMERIC (14,0)))    
      ,@FT1_TOTIBB = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,20,11) AS FLOAT))/100 AS NUMERIC(20,2)))    
      ,@FT1_TOTCUR = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,31,11) AS FLOAT))/100 AS NUMERIC(20,2) ))  
      ,@FT1_TOTCOV = SUM(CAST(SUBSTRING(DATACOLUMN,42,8) AS NUMERIC (20,0) ))          
  FROM dbo.TB_UDMH_X02  
  WITH (NOLOCK)    
 WHERE RECORDTYPE ='X02_GT1' 
   AND X02KEY NOT IN 
       (SELECT EXCEPT_SRCFIELD_1 
          FROM TB_UDMH_EXCEPTION 
         WHERE EXCEPT_SEVERITY ='E');    
       
-- FIND OUT SIGNS FOR  FT1_TOTIBB &  FT1_TOTCUR    
       
IF @FT1_TOTIBB >= 0     
 SET @GT1_SIGN1 = '+'    
ELSE    
 SET @GT1_SIGN1 = '-';    
        
IF @FT1_TOTCUR >= 0     
 SET @GT1_SIGN2 = '+'    
ELSE    
 SET @GT1_SIGN2 = '-';     
        
-- Store the absolute value of  FT1_TOTIBB &  FT1_TOTCUR    
-- as we are going to store sign in seperate field ( as above)    
        
SET @FT1_TOTIBB = ABS(@FT1_TOTIBB);           
SET @FT1_TOTCUR = ABS(@FT1_TOTCUR);    
     
SET @FT1_TOTIBB_CHAR = CAST(@FT1_TOTIBB AS CHAR(21));   
SET @FT1_TOTCUR_CHAR = CAST(@FT1_TOTCUR AS CHAR(21));     
   
       
UPDATE dbo.TB_UDMH_X02 WITH (ROWLOCK)   
   SET DATACOLUMN = 'FT1'+    
       RIGHT(REPLICATE('0',10) + CAST(@ROW_COUNT AS VARCHAR(10)) , 10)+    
       RIGHT(REPLICATE('0',12) + CAST(@FT1_TOTADV AS VARCHAR(12)) , 12)+    
       @GT1_SIGN1+    
       RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTIBB_CHAR,1,LEN(@FT1_TOTIBB_CHAR) -3)+ SUBSTRING(@FT1_TOTIBB_CHAR,LEN(@FT1_TOTIBB_CHAR)-1,LEN(@FT1_TOTIBB_CHAR))))) , 14)+    
       @GT1_SIGN2+    
       RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTCUR_CHAR,1,LEN(@FT1_TOTCUR_CHAR) -3)+ SUBSTRING(@FT1_TOTCUR_CHAR,LEN(@FT1_TOTCUR_CHAR)-1,LEN(@FT1_TOTCUR_CHAR))))) , 14)+    
       RIGHT(REPLICATE('0',12) + CAST(@FT1_TOTCOV AS VARCHAR(12)) , 12) 
  WHERE RECORDTYPE = 'X02_FT1' ;     
         
END;    


GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PR_X02_GT1_UPDATE') AND type in (N'P',N'PC'))
DROP PROCEDURE dbo.PR_X02_GT1_UPDATE   
GO  


CREATE PROCEDURE [dbo].[PR_X02_GT1_UPDATE]     
AS      
SET NOCOUNT ON;          
BEGIN      
    
--DELETE FROM TB_UDMH_X02GT1_ROW_COUNT WHICH ARE INSERTED EARLIER   
 
IF (SELECT COUNT(*) 
      FROM dbo.TB_UDMH_X02_GT1_UPDATE  
      WITH (NOLOCK)) >= 1      
BEGIN       
  DELETE FROM dbo.TB_UDMH_X02_GT1_UPDATE 
END      
     
--INSERT LATEST DATA TO TB_UDMH_X02GT1_ROW_COUNT         

;WITH                
 TB_X02_MAIN AS (            
   SELECT X02KEY      
         ,RECORDTYPE         
         ,SORDER     
         ,DATACOLUMN             
     FROM TB_UDMH_X02 
     WITH (NOLOCK)           
    WHERE RECORDTYPE = 'X02_GT1'             
 ),            
 TB_X02_NOHT AS (            
   SELECT X02KEY          
         ,COUNT(X02KEY) AS GT1_TOTREC            
     FROM dbo.TB_UDMH_X02 
     WITH (NOLOCK)           
    WHERE RECORDTYPE NOT IN ('X02_FH1','X02_GH1','X02_GT1','X02_FT1')               
    GROUP BY X02KEY             
 ),            
 TB_X02_FINAL AS (            
   SELECT X02_MAIN.X02KEY      
         ,RECORDTYPE            
         ,SORDER           
         ,SUBSTRING(DATACOLUMN,1,3)+ RIGHT(REPLICATE('0',8) + CAST(CAST(GT1_TOTREC AS INT) AS VARCHAR(8)), 8)+ SUBSTRING(DATACOLUMN,12,2000) AS DATACOLUMN           
     FROM TB_X02_MAIN AS X02_MAIN
    INNER JOIN TB_X02_NOHT AS X02_NOHT
       ON X02_MAIN.X02KEY = X02_NOHT.X02KEY             
 )         
           
INSERT INTO  dbo.TB_UDMH_X02_GT1_UPDATE        
SELECT X02KEY,RECORDTYPE,SORDER,DATACOLUMN 
  FROM TB_X02_FINAL 
  WITH (NOLOCK)    

IF (SELECT COUNT(*)  
    FROM dbo.TB_UDMH_X02 WITH (NOLOCK) 
   WHERE RECORDTYPE='X02_GT1') >= 1
  
BEGIN
  DELETE FROM dbo.TB_UDMH_X02 WHERE RECORDTYPE='X02_GT1';
END
          
INSERT INTO TB_UDMH_X02
SELECT X02_KEY
      ,RECORDTYPE
      ,SORDER
      ,DATACOLUMN 
 FROM dbo.TB_UDMH_X02_GT1_UPDATE
            
END  
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PR_X02_FT1_SPLIT') AND type in (N'P',N'PC'))
DROP PROCEDURE dbo.PR_X02_FT1_SPLIT   
GO  

CREATE PROCEDURE dbo.PR_X02_FT1_SPLIT  
(  
   @START_AT INT
  ,@END_AT INT
   --@FT1DATACOLUMN varchar(2000) output
)
AS
SET NOCOUNT ON;    
BEGIN    
     
DECLARE @ROW_COUNT NUMERIC(10,0) ;    -- To hold ROW COUNTS all Account(SOURCE-ID) IN X02 Table    
DECLARE @DATACOLUMN VARCHAR(2000);   -- To hold "DATACOLUMN" column of X02 table.    
DECLARE @FT1_TOTADV NUMERIC (14,0) ; -- To hold sum of [GT1-TOTADV] column of all Accounts    
DECLARE @FT1_TOTIBB NUMERIC (20,2) ; -- AG Changed from (12,2) to (20,2)    
DECLARE @FT1_TOTCUR NUMERIC (20,2) ; -- AG Changed from (12,2) to (20,2)    
DECLARE @FT1_TOTCOV NUMERIC (20,0) ; -- AG Changed from (12,0) to (20,0)    
DECLARE @GT1_SIGN1 CHAR(1) ;   -- To Hold sign for  FT1_TOTIBB column    
DECLARE @GT1_SIGN2 CHAR(1) ;   -- To Hold sign for  FT1_TOTCUR column    
DECLARE @FT1_TOTIBB_CHAR CHAR(15);    
DECLARE @FT1_TOTCUR_CHAR CHAR(15);    
      
SELECT  @ROW_COUNT  = SUM(CAST(SUBSTRING(DATACOLUMN,4,8) AS NUMERIC(10,0)))   
       ,@FT1_TOTADV = SUM(CAST(SUBSTRING( DATACOLUMN,12,8) AS  NUMERIC (14,0)))     
       ,@FT1_TOTIBB = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,20,11) AS FLOAT))/100 AS NUMERIC(20,2)))     
       ,@FT1_TOTCUR = SUM(CAST((CAST(SUBSTRING(DATACOLUMN,31,11) AS FLOAT))/100 AS NUMERIC(20,2) ))  
       ,@FT1_TOTCOV = SUM(CAST(SUBSTRING(DATACOLUMN,42,8) AS NUMERIC (20,0) ))           
 FROM dbo.TB_UDMH_X02_SPLIT  
 WITH (NOLOCK)    
WHERE RECORDTYPE ='X02_GT1' 
  AND GROUP_RANK BETWEEN @START_AT AND @END_AT;    
       
-- FIND OUT SIGNS FOR  FT1_TOTIBB &  FT1_TOTCUR    
       
IF @FT1_TOTIBB >= 0     
 SET @GT1_SIGN1 = '+'    
ELSE    
 SET @GT1_SIGN1 = '-';    
        
IF @FT1_TOTCUR >= 0     
 SET @GT1_SIGN2 = '+'    
ELSE    
 SET @GT1_SIGN2 = '-';     
        
-- Store the absolute value of  FT1_TOTIBB &  FT1_TOTCUR    
-- as we are going to store sign in seperate field ( as above)    
        
SET @FT1_TOTIBB = ABS(@FT1_TOTIBB);           
SET @FT1_TOTCUR = ABS(@FT1_TOTCUR);    
       
SET @FT1_TOTIBB_CHAR = CAST(@FT1_TOTIBB AS CHAR(21)); 
SET @FT1_TOTCUR_CHAR = CAST(@FT1_TOTCUR AS CHAR(21)); 
   
SELECT 'FT1'+    
        RIGHT(REPLICATE('0',10) + CAST(@ROW_COUNT AS VARCHAR(10)) , 10)+    
        RIGHT(REPLICATE('0',12) + CAST(@FT1_TOTADV AS VARCHAR(12)) , 12)+    
        @GT1_SIGN1+    
        RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTIBB_CHAR,1,LEN(@FT1_TOTIBB_CHAR) -3)+ SUBSTRING(@FT1_TOTIBB_CHAR,LEN(@FT1_TOTIBB_CHAR)-1,LEN(@FT1_TOTIBB_CHAR))))) , 14)+    
        @GT1_SIGN2+    
        RIGHT(REPLICATE('0',14) + LTRIM(RTRIM((SUBSTRING(@FT1_TOTCUR_CHAR,1,LEN(@FT1_TOTCUR_CHAR) -3)+ SUBSTRING(@FT1_TOTCUR_CHAR,LEN(@FT1_TOTCUR_CHAR)-1,LEN(@FT1_TOTCUR_CHAR))))) , 14)+    
        RIGHT(REPLICATE('0',12) + CAST(@FT1_TOTCOV AS VARCHAR(12)) , 12)    
         
END;    


GO