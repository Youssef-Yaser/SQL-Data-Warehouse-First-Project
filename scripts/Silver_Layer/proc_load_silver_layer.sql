/*
    ⚠️ WARNING - SILVER LAYER LOAD PROCEDURE
    -----------------------------------------------------------------------------------------
    📌 Name:
        Silver.Load_Silver_Layer

    🎯 Purpose:
        This procedure loads the Silver layer by 
        cleaning and transforming data from the Bronze layer.

    ⚡ What It Does:
        - Truncates Silver tables
        - Loads data from Bronze tables
        - Cleans, transforms, and standardizes the data
        - Prints execution time and handles errors

    📁 Usage:
        Run this procedure after Bronze layer has been fully loaded

    ⚙️ Parameters:
        None

    💡 Example:
        EXEC Silver.Load_Silver_Layer;
*/

--EXEC Silver.Load_Silver_Layer

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE Silver.Load_Silver_Layer
AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @table_start DATETIME, @table_end DATETIME;

    BEGIN TRY

        SET @start_time = GETDATE();

        PRINT '========================================================'
        PRINT '             Starting Silver Layer Load Process          '
        PRINT '========================================================'
        PRINT ''

        ----------------------------------------------------------------
        -- CRM TABLES
        ----------------------------------------------------------------
        PRINT '--------------------------------------------------------'
        PRINT ' Step 1: Loading CRM Tables'
        PRINT '--------------------------------------------------------'

        ---------------- crm_cust_info ----------------
		PRINT '========================'
        PRINT 'Silver.crm_cust_info'
        TRUNCATE TABLE [Silver].[crm_cust_info];

        SET @table_start = GETDATE();

        INSERT INTO Silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
                ELSE 'Unknown'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
                ELSE 'Unknown'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag
            FROM Bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE Flag = 1;

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ---------------- crm_prd_info ----------------
		PRINT '========================'
        PRINT 'Silver.crm_prd_info'
        TRUNCATE TABLE [Silver].[crm_prd_info];

        SET @table_start = GETDATE();

        INSERT INTO Silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'Unknown'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            )
        FROM Bronze.crm_prd_info;

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ---------------- crm_sales_details ----------------
		PRINT '========================';
        PRINT 'Silver.crm_sales_details'
        TRUNCATE TABLE [Silver].[crm_sales_details];

        SET @table_start = GETDATE();

        INSERT INTO Silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id,
            sls_order_dt, sls_ship_dt, sls_due_dt,
            sls_sales, sls_quantity, sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS varchar) AS DATE)
            END,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS varchar) AS DATE)
            END,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS varchar) AS DATE)
            END,
            CASE 
                WHEN sls_sales IS NULL 
                     OR sls_sales <= 0 
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL 
                     OR sls_price = 0 
                THEN sls_sales / NULLIF(sls_quantity,0)
                WHEN sls_price < 0 THEN ABS(sls_price)
                ELSE sls_price
            END
        FROM Bronze.crm_sales_details;

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
		PRINT '========================';
        PRINT 'Silver.erp_cust_az12'
        TRUNCATE TABLE [Silver].[erp_cust_az12];

        SET @table_start = GETDATE();

        INSERT INTO Silver.erp_cust_az12 (CID, BDATE, GEN)
        SELECT 
            CASE 
                WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) 
                ELSE CID
            END,
            CASE 
                WHEN BDATE < '1924-01-01' OR BDATE > GETDATE() THEN NULL
                ELSE BDATE
            END,
            CASE 
                WHEN UPPER(GEN) IN ('F','FEMALE') THEN 'Female'
                WHEN UPPER(GEN) IN ('M','MALE') THEN 'Male'
                ELSE 'Unknown'
            END
        FROM Bronze.erp_cust_az12;

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ---------------- erp_loc_a101 ----------------
		PRINT '========================';
        PRINT 'Silver.erp_loc_a101'
        TRUNCATE TABLE [Silver].[erp_loc_a101];

        SET @table_start = GETDATE();

        INSERT INTO Silver.erp_loc_a101 (CID, CNTRY)
        SELECT 
            REPLACE(CID, '-', ''),
            CASE 
                WHEN UPPER(TRIM(CNTRY)) IN ('US', 'USA') THEN 'United States'
                WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Germany'
                WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN 'Unknown'
                ELSE TRIM(CNTRY)
            END
        FROM Bronze.erp_loc_a101;

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ---------------- erp_px_cat_g1v2 ----------------
		PRINT '========================';
        PRINT 'Silver.erp_px_cat_g1v2'
        TRUNCATE TABLE [Silver].[erp_px_cat_g1v2];

        SET @table_start = GETDATE();

        INSERT INTO Silver.erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENANCE)
        SELECT 
            ID, CAT, SUBCAT, MAINTENANCE
        FROM Bronze.erp_px_cat_g1v2;

        SET @table_end = GETDATE();
        PRINT '  -> Done in ' + CAST(DATEDIFF(SECOND, @table_start, @table_end) AS NVARCHAR) + ' sec'
        PRINT ''


        ----------------------------------------------------------------
        -- FINISH
        ----------------------------------------------------------------
        PRINT '========================================================'
        PRINT '         Silver Layer Load Completed Successfully         '
        PRINT '========================================================'

        SET @end_time = GETDATE();
        PRINT 'Total Duration : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';

    END TRY
    BEGIN CATCH
        PRINT '========================================================'
        PRINT '        ERROR OCCURRED DURING LOADING SILVER LAYER        '
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================================'
    END CATCH
END;
GO

