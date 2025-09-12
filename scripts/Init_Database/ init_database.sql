/*
================================================================================
📌 DESCRIPTION:
This script will:
1. Check if a database named [DataWarehouse] already exists.
2. If it exists, it will:
   - Force it into SINGLE_USER mode (to close any open connections)
   - Drop (delete) the database completely.
3. Create a new empty [DataWarehouse] database.
4. Create three schemas inside it: [Bronze], [Silver], [Gold].
=================================================================================
⚠️ WARNING:
- This script will PERMANENTLY DELETE the existing [DataWarehouse] database if it exists.
- All existing data, tables, views, and stored procedures inside it will be lost.
- Make sure you have a backup before running this script in a production environment.
*/

-- 🔻 Step 1: Drop the database if it already exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

-- ✅ Step 2: Create the new database
CREATE DATABASE DataWarehouse;
GO

-- ✅ Step 3: Switch to the new database
USE DataWarehouse;
GO

-- ✅ Step 4: Create the three schemas
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO
