/*
    ⚠️ WARNING - DANGEROUS SCRIPT
    -----------------------------------------------------------------------------------------
    This script will DROP and recreate all Bronze layer tables used for the Data Warehouse project.
    It is intended for INITIAL SETUP only.

    - Running this script will DELETE existing tables
    - All tables are created WITHOUT primary keys or constraints
    - All columns are NULLABLE to support raw bulk data loading
    - Use only in a DEVELOPMENT or SANDBOX environment

    📦 Schema: Bronze
    📁 Usage: To store raw unprocessed CRM and ERP data files as-is
*/

USE DataWarehouse;
GO

-- Create schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Bronze')
    EXEC('CREATE SCHEMA Bronze');
GO


/*
    TABLE: Bronze.crm_cust_info
    📌 Description: Raw CRM customers info (basic customer demographics and status)
*/
IF OBJECT_ID('[Bronze].[crm_cust_info]', 'U') IS NOT NULL
    DROP TABLE [Bronze].[crm_cust_info];

CREATE TABLE [Bronze].[crm_cust_info] (
    cst_id              NVARCHAR(50)     NULL,
    cst_key             NVARCHAR(50)     NULL,
    cst_firstname       NVARCHAR(50)     NULL,
    cst_lastname        NVARCHAR(50)     NULL,
    cst_marital_status  NVARCHAR(50)     NULL,
    cst_gndr             NVARCHAR(50)     NULL,
    cst_create_date      DATE             NULL
);
GO


/*
    TABLE: Bronze.crm_prd_info
    📌 Description: Raw CRM product master data (product attributes and lifecycle dates)
*/
IF OBJECT_ID('[Bronze].[crm_prd_info]', 'U') IS NOT NULL
    DROP TABLE [Bronze].[crm_prd_info];

CREATE TABLE [Bronze].[crm_prd_info] (
    prd_id         INT               NULL,
    prd_key        NVARCHAR(50)      NULL,
    prd_nm         NVARCHAR(50)      NULL,
    prd_cost       INT               NULL,
    prd_line       NVARCHAR(50)      NULL,
    prd_start_dt   DATETIME           NULL,
    prd_end_dt     DATETIME           NULL
);
GO


/*
    TABLE: Bronze.crm_sales_details
    📌 Description: Raw CRM sales transactions (sales order, customer, quantity, revenue)
*/
IF OBJECT_ID('[Bronze].[crm_sales_details]', 'U') IS NOT NULL
    DROP TABLE [Bronze].[crm_sales_details];

CREATE TABLE [Bronze].[crm_sales_details] (
    sls_ord_num     NVARCHAR(50)     NULL,
    sls_prd_key     NVARCHAR(50)     NULL,
    sls_cust_id     INT               NULL,
    sls_order_dt    INT               NULL,
    sls_ship_dt     INT               NULL,
    sls_due_dt      INT               NULL,
    sls_sales       INT               NULL,
    sls_quantity    INT               NULL,
    sls_price       INT               NULL
);
GO


/*
    TABLE: Bronze.erp_cust_az12
    📌 Description: Raw ERP customer data (ID, birthdate, gender)
*/
IF OBJECT_ID('[Bronze].[erp_cust_az12]', 'U') IS NOT NULL
    DROP TABLE [Bronze].[erp_cust_az12];

CREATE TABLE [Bronze].[erp_cust_az12] (
    CID      NVARCHAR(50)     NULL,
    BDATE    DATE               NULL,
    GEN      NVARCHAR(50)     NULL
);
GO


/*
    TABLE: Bronze.erp_loc_a101
    📌 Description: Raw ERP location data (customer ID with associated country)
*/
IF OBJECT_ID('[Bronze].[erp_loc_a101]', 'U') IS NOT NULL
    DROP TABLE [Bronze].[erp_loc_a101];

CREATE TABLE [Bronze].[erp_loc_a101] (
    CID       NVARCHAR(50)     NULL,
    CNTRY     NVARCHAR(50)     NULL
);
GO


/*
    TABLE: Bronze.erp_px_cat_g1v2
    📌 Description: Raw ERP product categories and maintenance flags
*/
IF OBJECT_ID('[Bronze].[erp_px_cat_g1v2]', 'U') IS NOT NULL
    DROP TABLE [Bronze].[erp_px_cat_g1v2];

CREATE TABLE [Bronze].[erp_px_cat_g1v2] (
    ID             NVARCHAR(50)     NULL,
    CAT            NVARCHAR(50)     NULL,
    SUBCAT         NVARCHAR(50)     NULL,
    MAINTENANCE    NVARCHAR(3)      NULL
);
GO
