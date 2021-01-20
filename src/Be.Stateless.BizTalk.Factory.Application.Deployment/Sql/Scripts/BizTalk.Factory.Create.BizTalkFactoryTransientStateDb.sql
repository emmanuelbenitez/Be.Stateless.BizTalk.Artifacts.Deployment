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

/****** Object:  Database [BizTalkFactoryTransientStateDb]  ******/
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'BizTalkFactoryTransientStateDb')
BEGIN
   ALTER DATABASE [BizTalkFactoryTransientStateDb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
   DROP DATABASE [BizTalkFactoryTransientStateDb]
END
GO

CREATE DATABASE [BizTalkFactoryTransientStateDb]
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BizTalkFactoryTransientStateDb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ANSI_NULL_DEFAULT OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ANSI_NULLS OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ANSI_PADDING OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ANSI_WARNINGS OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ARITHABORT OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET AUTO_CLOSE OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET AUTO_SHRINK OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET AUTO_UPDATE_STATISTICS ON
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET CURSOR_CLOSE_ON_COMMIT OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET CURSOR_DEFAULT  GLOBAL
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET CONCAT_NULL_YIELDS_NULL OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET NUMERIC_ROUNDABORT OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET QUOTED_IDENTIFIER OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET RECURSIVE_TRIGGERS OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET  DISABLE_BROKER
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET DATE_CORRELATION_OPTIMIZATION OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET TRUSTWORTHY OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET PARAMETERIZATION SIMPLE
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET READ_COMMITTED_SNAPSHOT OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET HONOR_BROKER_PRIORITY OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET RECOVERY FULL
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET  MULTI_USER
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET PAGE_VERIFY CHECKSUM
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET DB_CHAINING OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF )
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET TARGET_RECOVERY_TIME = 60 SECONDS
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET DELAYED_DURABILITY = DISABLED
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET ACCELERATED_DATABASE_RECOVERY = OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET QUERY_STORE = OFF
GO

ALTER DATABASE [BizTalkFactoryTransientStateDb] SET  READ_WRITE
GO

USE [BizTalkFactoryTransientStateDb]
GO

/****** [BizTalkFactoryTransientStateDb] Object:  USER and ROLES ******/
CREATE USER [$(BizTalkAdministratorGroup)] FOR LOGIN [$(BizTalkAdministratorGroup)]
EXEC dbo.sp_addrolemember @rolename=N'db_owner', @membername=N'$(BizTalkAdministratorGroup)'
GO

CREATE ROLE [BTS_USERS] AUTHORIZATION [dbo]
GO

EXEC sp_addrolemember @rolename=N'db_datareader', @membername=N'BTS_USERS'
GO

EXEC sp_addrolemember @rolename=N'db_datawriter', @membername=N'BTS_USERS'
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
