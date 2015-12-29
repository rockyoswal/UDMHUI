/*
  AUTHOR: AMIT KUMAR SINGH
  PROJECT: PHOENIX
  CREATION DATE: 01-JUL-2015
  DESCRIPTION: THIS SQL CODE IS USED TO CREATE SOURCE/STAGING DATABASE AND UDMH_METRICS DATABASE.

  REVISION HISTORY:
 -----------------------------------------------------------------------------------------------------
  VERSION    	DATE        	DEVELOPER         		DESCRIPTION
 -----------------------------------------------------------------------------------------------------
    1.0         01-JUL-2015		AMIT					INITIAL DRAFT   
	2.0         12-AUG-2015		GIREESH					CHANGED AS PER THE REVIEW COMMENTS    
 -----------------------------------------------------------------------------------------------------
 */


CREATE PROCEDURE [dbo].[CreateDB] @DBDATAPATH nvarchar(30),@DBNAME nvarchar(30)

AS
--1. CREATIMG STAGING DATABASE
/* DECLARE VARIBLE TO STORE THE DATABASE NAME, AND DATA PATH ETC. */
--DECLARE @DBDATAPATH VARCHAR(MAX) = "$(varDBPATH)"
--, @DBNAME VARCHAR(50) = '$(VARDBNAME)'  -- SET THE SQL DATABASE NAME IN THE MAIN DBSETUP.BAT FILE E.G. 'PHOENIX_UDMH_RB_TEST'.
DECLARE @SQLSTR VARCHAR(MAX) -- DEFINE THE SUFFICIENT LENGTH TO STORE THE ENTIRE DB CREATE STATEMENT

SET @SQLSTR = 'IF  EXISTS (SELECT NAME FROM SYS.DATABASES WHERE NAME = N''' + @DBNAME + ''')
BEGIN
ALTER DATABASE [' + @DBNAME + '] set single_user with rollback immediate
DROP DATABASE [' + @DBNAME + '] 
END'

EXEC (@SQLSTR)

SET @SQLSTR = 'CREATE DATABASE [' + @DBNAME +'] ON  PRIMARY 
( NAME = N'''+ @DBNAME + ''', FILENAME = N'''+ @DBDATAPATH + @DBNAME +'.MDF'' , SIZE = 204800KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'''+ @DBNAME + '_LOG'', FILENAME = N''' + @DBDATAPATH +  @DBNAME +'_LOG.LDF'' , SIZE = 20480KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)'
EXEC (@SQLSTR) 

--2. CREATING UDMH METRICS DATABASE
IF NOT  EXISTS (SELECT NAME FROM SYS.DATABASES WHERE NAME = N'UDMH_METRICS')
BEGIN
    SET @SQLSTR = 'CREATE DATABASE [UDMH_METRICS] ON  PRIMARY 
    ( NAME = UDMH_METRICS, FILENAME = N'''+ @DBDATAPATH +'UDMH_METRICS.MDF'' , SIZE = 204800KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )'
    +' LOG ON 
    ( NAME = N''UDMH_METRICS_LOG'', FILENAME = N''' + @DBDATAPATH +'UDMH_METRICS_LOG.LDF'' , SIZE = 20480KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)'

    EXEC (@SQLSTR)
END