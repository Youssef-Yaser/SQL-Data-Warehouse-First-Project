/*
    ⚠️ WARNING - DATA TRANSFORMATION SCRIPT
    -----------------------------------------------------------------------------------------
    This script will DROP and recreate all Silver layer tables used for the Data Warehouse project.
    It is intended for building the TRANSFORMATION layer (Silver).

    - Running this script will DELETE existing tables
    - Silver layer is used to CLEAN, FILTER, and TRANSFORM raw data coming from the Bronze layer
    - Tables in this layer are used as the foundation for building curated data in the Gold layer
    - Use only in a DEVELOPMENT or SANDBOX environment when redesigning the Silver schema

    📦 Schema: Silver
    📁 Usage: To store cleaned and transformed data after processing Bronze layer raw data
*/


USE DataWarehouse;
GO

-- Create schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Silver')
    EXEC('CREATE SCHEMA Silver');
GO


/*
    TABLE: Silver.crm_cust_info
    📌 Description: Raw CRM customers info (basic customer demographics and status)
*/
IF OBJECT_ID('[Silver].[crm_cust_info]', 'U') IS NOT NULL
    DROP TABLE [Silver].[crm_cust_info];

CREATE TABLE [Silver].[crm_cust_info] (
    cst_id              NVARCHAR(50)     NULL,
    cst_key             NVARCHAR(50)     NULL,
    cst_firstname       NVARCHAR(50)     NULL,
    cst_lastname        NVARCHAR(50)     NULL,
    cst_marital_status  NVARCHAR(50)     NULL,
    cst_gndr             NVARCHAR(50)     NULL,
    cst_create_date      DATE             NULL ,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
    TABLE: Silver.crm_prd_info
    📌 Description: Raw CRM product master data (product attributes and lifecycle dates)
*/
IF OBJECT_ID('[Silver].[crm_prd_info]', 'U') IS NOT NULL
    DROP TABLE [Silver].[crm_prd_info];

CREATE TABLE [Silver].[crm_prd_info] (
    prd_id         INT               NULL,
	cat_id         NVARCHAR(50)      NULL,
    prd_key        NVARCHAR(50)      NULL,
    prd_nm         NVARCHAR(50)      NULL,
    prd_cost       INT               NULL,
    prd_line       NVARCHAR(50)      NULL,
    prd_start_dt   DATE           NULL,
    prd_end_dt     DATE           NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
    TABLE: Silver.crm_sales_details
    📌 Description: Raw CRM sales transactions (sales order, customer, quantity, revenue)
*/
IF OBJECT_ID('[Silver].[crm_sales_details]', 'U') IS NOT NULL
    DROP TABLE [Silver].[crm_sales_details];

CREATE TABLE [Silver].[crm_sales_details] (
    sls_ord_num     NVARCHAR(50)     NULL,
    sls_prd_key     NVARCHAR(50)     NULL,
    sls_cust_id     INT               NULL,
    sls_order_dt    DATE               NULL,
    sls_ship_dt     DATE               NULL,
    sls_due_dt      DATE               NULL,
    sls_sales       INT               NULL,
    sls_quantity    INT               NULL,
    sls_price       INT               NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
    TABLE: Silver.erp_cust_az12
    📌 Description: Raw ERP customer data (ID, birthdate, gender)
*/
IF OBJECT_ID('[Silver].[erp_cust_az12]', 'U') IS NOT NULL
    DROP TABLE [Silver].[erp_cust_az12];

CREATE TABLE [Silver].[erp_cust_az12] (
    CID      NVARCHAR(50)     NULL,
    BDATE    DATE               NULL,
    GEN      NVARCHAR(50)     NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
    TABLE: Silver.erp_loc_a101
    📌 Description: Raw ERP location data (customer ID with associated country)
*/
IF OBJECT_ID('[Silver].[erp_loc_a101]', 'U') IS NOT NULL
    DROP TABLE [Silver].[erp_loc_a101];

CREATE TABLE [Silver].[erp_loc_a101] (
    CID       NVARCHAR(50)     NULL,
    CNTRY     NVARCHAR(50)     NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
    TABLE: Silver.erp_px_cat_g1v2
    📌 Description: Raw ERP product categories and maintenance flags
*/
IF OBJECT_ID('[Silver].[erp_px_cat_g1v2]', 'U') IS NOT NULL
    DROP TABLE [Silver].[erp_px_cat_g1v2];

CREATE TABLE [Silver].[erp_px_cat_g1v2] (
    ID             NVARCHAR(50)     NULL,
    CAT            NVARCHAR(50)     NULL,
    SUBCAT         NVARCHAR(50)     NULL,
    MAINTENANCE    NVARCHAR(3)      NULL,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
