/*
 Copyright © 2012 - 2021 François Chabot

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

USE [master]
GO

/****** Object:  Database [BizTalkFactoryMgmtDb] ******/
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'BizTalkFactoryMgmtDb')
BEGIN
   ALTER DATABASE [BizTalkFactoryMgmtDb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
   DROP DATABASE [BizTalkFactoryMgmtDb]
END
GO

CREATE DATABASE [BizTalkFactoryMgmtDb]
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BizTalkFactoryMgmtDb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ANSI_NULL_DEFAULT OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ANSI_NULLS OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ANSI_PADDING OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ANSI_WARNINGS OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ARITHABORT OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET AUTO_CLOSE OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET AUTO_SHRINK OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET AUTO_UPDATE_STATISTICS ON
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET CURSOR_CLOSE_ON_COMMIT OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET CURSOR_DEFAULT  GLOBAL
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET CONCAT_NULL_YIELDS_NULL OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET NUMERIC_ROUNDABORT OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET QUOTED_IDENTIFIER OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET RECURSIVE_TRIGGERS OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET  DISABLE_BROKER
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET DATE_CORRELATION_OPTIMIZATION OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET TRUSTWORTHY OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET PARAMETERIZATION SIMPLE
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET READ_COMMITTED_SNAPSHOT OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET HONOR_BROKER_PRIORITY OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET RECOVERY FULL
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET  MULTI_USER
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET PAGE_VERIFY CHECKSUM
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET DB_CHAINING OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF )
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET TARGET_RECOVERY_TIME = 60 SECONDS
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET DELAYED_DURABILITY = DISABLED
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET ACCELERATED_DATABASE_RECOVERY = OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET QUERY_STORE = OFF
GO

ALTER DATABASE [BizTalkFactoryMgmtDb] SET  READ_WRITE
GO

USE [BizTalkFactoryMgmtDb]
GO

/****** [BizTalkFactoryMgmtDb] Object:  USER and ROLES ******/
CREATE USER [$(BizTalkAdministratorGroup)] FOR LOGIN [$(BizTalkAdministratorGroup)]
EXEC dbo.sp_addrolemember @rolename=N'db_owner', @membername=N'$(BizTalkAdministratorGroup)'
GO

CREATE ROLE [BTS_USERS] AUTHORIZATION [dbo]
GO

EXEC dbo.sp_addrolemember @rolename=N'db_datareader', @membername=N'BTS_USERS'
GO

DECLARE @rowNumber INT = 0
DECLARE @group nvarchar(128)
WHILE (1 = 1)
BEGIN
   WITH Groups AS (
      SELECT ROW_NUMBER() OVER(ORDER BY value ASC) AS RowNumber, value AS [Group]
      FROM STRING_SPLIT(N'$(BizTalkHostUserGroups)', ';')
   )
   SELECT TOP 1 @rowNumber = RowNumber, @group = TRIM([Group])
   FROM Groups
   WHERE RowNumber > @rowNumber

   IF @@ROWCOUNT = 0 BREAK;

   DECLARE @statement nvarchar(512) = CONCAT('CREATE USER ', quotename(@group), ' FOR LOGIN ' , quotename(@group))
   IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name=@group)
      EXEC(@statement)

   EXEC dbo.sp_addrolemember @rolename=N'BTS_USERS', @membername=@group
END
GO
