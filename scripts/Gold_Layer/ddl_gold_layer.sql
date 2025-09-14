/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
    - Running this script will DELETE and recreate existing Gold views.
    - Use only in a DEVELOPMENT or SANDBOX environment when redesigning the Gold schema.

⚠️ WARNING:
    - Gold layer is used to PRESENT clean, curated, business-ready data.
    - Tables/Views in this layer depend on data from the Silver layer.
    - Make sure you have a backup or are working in a development environment.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Create Dimension: Gold.dim_customers
-- =============================================================================
IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW Gold.dim_customers;
GO

CREATE VIEW Gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY CI.cst_id) AS customer_key,
    CI.cst_id          AS customer_id,
    CI.cst_key         AS customer_number,
    CI.cst_firstname   AS first_name,
    CI.cst_lastname    AS last_name,
    LA.CNTRY            AS country,
    CI.cst_marital_status AS marital_status,
    CASE 
        WHEN CI.cst_gndr != 'Unknown' 
            THEN CI.cst_gndr
        ELSE COALESCE(CA.GEN, 'Unknown')
    END AS gender,
    CA.BDATE            AS birthdate,
    CI.cst_create_date  AS create_date
FROM Silver.crm_cust_info CI
LEFT JOIN Silver.erp_cust_az12  CA ON CI.cst_key = CA.CID
LEFT JOIN Silver.erp_loc_a101   LA ON CI.cst_key = LA.CID;


USE DataWarehouse;
GO

-- =============================================================================
-- Create Dimension: Gold.dim_products
-- =============================================================================
IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
    DROP VIEW Gold.dim_products;
GO

CREATE VIEW Gold.dim_products AS 
SELECT
    ROW_NUMBER () OVER (ORDER BY PN.prd_start_dt , PN.prd_id) AS product_key,
    PN.prd_id AS product_id,
    PN.prd_key AS product_number,
    PN.prd_nm  AS product_name,
    PN.cat_id AS category_id,
    PC.CAT AS category,
    PC.SUBCAT AS  subcategory,
    PC.MAINTENANCE AS maintenance,
    PN.prd_cost  AS cost,
    PN.prd_line AS product_line,
    PN.prd_start_dt  AS start_date
FROM Silver.crm_prd_info PN
LEFT JOIN Silver.erp_px_cat_g1v2 PC
    ON PN.cat_id = PC.ID
WHERE PN.prd_end_dt IS NULL;


USE DataWarehouse;
GO

-- =============================================================================
-- Create Fact: Gold.fact_sales
-- =============================================================================
IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.fact_sales;
GO

CREATE VIEW Gold.fact_sales AS
SELECT 
    SD.sls_ord_num    AS order_number,
    PR.product_key    AS product_key,
    CU.customer_key   AS customer_key,
    SD.sls_order_dt   AS order_date,
    SD.sls_ship_dt    AS shipping_date,
    SD.sls_due_dt     AS due_date,
    SD.sls_sales      AS sales_amount,
    SD.sls_quantity   AS quantity,
    SD.sls_price      AS price
FROM Silver.crm_sales_details SD
LEFT JOIN Gold.dim_products PR
    ON PR.product_number = SD.sls_prd_key
LEFT JOIN Gold.dim_customers CU
    ON CU.customer_id = SD.sls_cust_id;
