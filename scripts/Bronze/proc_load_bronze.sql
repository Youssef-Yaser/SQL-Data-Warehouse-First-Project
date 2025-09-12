/********************************************************************************************
    ⚠️ WARNING - DANGEROUS PROCEDURE
    -----------------------------------------------------------------------------------------
    This stored procedure will TRUNCATE and BULK INSERT data into all Bronze layer tables.
    Running it will DELETE all existing data and reload from CSV source files.

    ✅ Intended Usage:
        - Development / sandbox environments only
        - For reloading raw CRM and ERP data from source CSV files

    ❌ Do NOT run this in production without proper backups

    📦 Schema: Bronze
    📁 Tables: crm_cust_info, crm_prd_info, crm_sales_details,
               erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2
    How to use it : 
    EXEC Bronze.load_bronze ;
********************************************************************************************/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE Bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @table_start DATETIME, @table_end DATETIME;

    BEGIN TRY

        SET @start_time = GETDATE();

        PRINT '========================================================'
        PRINT '             Starting Bronze Layer Load Process          '
        PRINT '========================================================'
        PRINT ''

        ----------------------------------------------------------------
        -- CRM TABLES
        ----------------------------------------------------------------
        PRINT '--------------------------------------------------------'
        PRINT ' Step 1: Loading CRM Tables'
        PRINT '--------------------------------------------------------'

        ---------------- crm_cust_info ----------------
        PRINT '[Bronze].[crm_cust_info]'
        TRUNCATE TABLE [Bronze].[crm_cust_info];

        SET @table_start = GETDATE();

        BULK INSERT [Bronze].[crm_cust_info]
        FROM 'D:\SQL Full Course - Data with Baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK );

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''

        ---------------- crm_prd_info ----------------
        PRINT '[Bronze].[crm_prd_info]'
        TRUNCATE TABLE [Bronze].[crm_prd_info];

        SET @table_start = GETDATE();

        BULK INSERT [Bronze].[crm_prd_info]
        FROM 'D:\SQL Full Course - Data with Baraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK );

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''

        ---------------- crm_sales_details ----------------
        PRINT '[Bronze].[crm_sales_details]'
        TRUNCATE TABLE [Bronze].[crm_sales_details];

        SET @table_start = GETDATE();

        BULK INSERT [Bronze].[crm_sales_details]
        FROM 'D:\SQL Full Course - Data with Baraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK );

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ----------------------------------------------------------------
        -- ERP TABLES
        ----------------------------------------------------------------
        PRINT '--------------------------------------------------------'
        PRINT ' Step 2: Loading ERP Tables'
        PRINT '--------------------------------------------------------'

        ---------------- erp_cust_az12 ----------------
        PRINT '[Bronze].[erp_cust_az12]'
        TRUNCATE TABLE [Bronze].[erp_cust_az12];

        SET @table_start = GETDATE();

        BULK INSERT [Bronze].[erp_cust_az12]
        FROM 'D:\SQL Full Course - Data with Baraa\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK );

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''

        ---------------- erp_loc_a101 ----------------
        PRINT '[Bronze].[erp_loc_a101]'
        TRUNCATE TABLE [Bronze].[erp_loc_a101];

        SET @table_start = GETDATE();

        BULK INSERT [Bronze].[erp_loc_a101]
        FROM 'D:\SQL Full Course - Data with Baraa\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK );

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''

        ---------------- erp_px_cat_g1v2 ----------------
        PRINT '[Bronze].[erp_px_cat_g1v2]'
        TRUNCATE TABLE [Bronze].[erp_px_cat_g1v2];

        SET @table_start = GETDATE();

        BULK INSERT [Bronze].[erp_px_cat_g1v2]
        FROM 'D:\SQL Full Course - Data with Baraa\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK );

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ----------------------------------------------------------------
        -- COUNTS
        ----------------------------------------------------------------
        PRINT '--------------------------------------------------------'
        PRINT ' Step 3: Row Counts After Load'
        PRINT '--------------------------------------------------------'

        SELECT 'crm_cust_info' AS TableName, COUNT(*) AS TotalRows FROM [Bronze].[crm_cust_info]
        UNION ALL
        SELECT 'crm_prd_info', COUNT(*) FROM [Bronze].[crm_prd_info]
        UNION ALL
        SELECT 'crm_sales_details', COUNT(*) FROM [Bronze].[crm_sales_details]
        UNION ALL
        SELECT 'erp_cust_az12', COUNT(*) FROM [Bronze].[erp_cust_az12]
        UNION ALL
        SELECT 'erp_loc_a101', COUNT(*) FROM [Bronze].[erp_loc_a101]
        UNION ALL
        SELECT 'erp_px_cat_g1v2', COUNT(*) FROM [Bronze].[erp_px_cat_g1v2];

        PRINT ''
        PRINT '========================================================'
        PRINT '         Bronze Layer Load Completed Successfully         '
        PRINT '========================================================'

        SET @end_time = GETDATE();
        PRINT 'Total Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

    END TRY
    BEGIN CATCH
        PRINT '========================================================'
        PRINT '        ERROR OCCURRED DURING LOADING BRONZE LAYER        '
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================================'
    END CATCH
END;
GO
