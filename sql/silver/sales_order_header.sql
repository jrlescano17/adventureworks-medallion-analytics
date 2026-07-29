WITH cleaned AS (
    SELECT
        CAST("SalesOrderID" AS INT)         AS sales_order_id,
        CAST("RevisionNumber" AS INT)       AS revision_number,
        CAST("OrderDate" AS DATE)           AS order_date,
        CAST("DueDate" AS DATE)             AS due_date,
        CAST("ShipDate" AS DATE)            AS ship_date,
        CAST("Status" AS INT)               AS order_status,
        CAST("OnlineOrderFlag" AS BOOLEAN)  AS is_online_order,
        TRIM("SalesOrderNumber")            AS sales_order_number,
        TRIM("PurchaseOrderNumber")         AS purchase_order_number,
        TRIM("AccountNumber")               AS account_number,
        CAST("CustomerID" AS INT)           AS customer_id,
        CAST("SalesPersonID" AS INT)        AS sales_person_id,
        CAST("TerritoryID" AS INT)          AS territory_id,
        CAST("BillToAddressID" AS INT)      AS bill_to_address_id,
        CAST("ShipToAddressID" AS INT)      AS ship_to_address_id,
        CAST("ShipMethodID" AS INT)         AS ship_method_id,
        CAST("CreditCardID" AS INT)         AS credit_card_id,
        TRIM("CreditCardApprovalCode")      AS credit_card_approval_code,
        CAST("CurrencyRateID" AS INT)       AS currency_rate_id,
        CAST("SubTotal" AS DOUBLE)          AS sub_total,
        CAST("TaxAmt" AS DOUBLE)            AS tax_amount,
        CAST("Freight" AS DOUBLE)           AS freight,
        CAST("TotalDue" AS DOUBLE)          AS total_due,
        TRIM("Comment")                     AS order_comment,
        CAST("ModifiedDate" AS TIMESTAMP)   AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/SalesSalesOrderHeader.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY sales_order_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    sales_order_id,
    revision_number,
    order_date,
    due_date,
    ship_date,
    order_status,
    is_online_order,
    sales_order_number,
    purchase_order_number,
    account_number,
    customer_id,
    sales_person_id,
    territory_id,
    bill_to_address_id,
    ship_to_address_id,
    ship_method_id,
    credit_card_id,
    credit_card_approval_code,
    currency_rate_id,
    sub_total,
    tax_amount,
    freight,
    total_due,
    order_comment,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1