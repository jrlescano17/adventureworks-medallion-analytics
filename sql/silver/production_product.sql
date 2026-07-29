WITH cleaned AS (
    SELECT
        CAST("ProductID" AS INT)                AS product_id,
        UPPER(TRIM("Name"))                     AS product_name,
        UPPER(TRIM("ProductNumber"))            AS product_number,
        CAST("MakeFlag" AS BOOLEAN)             AS make_flag,
        CAST("FinishedGoodsFlag" AS BOOLEAN)    AS finished_goods_flag,
        UPPER(TRIM("Color"))                    AS color,
        CAST("SafetyStockLevel" AS INT)         AS safety_stock_level,
        CAST("ReorderPoint" AS INT)             AS reorder_point,
        CAST("StandardCost" AS DOUBLE)          AS standard_cost,
        CAST("ListPrice" AS DOUBLE)             AS list_price,
        UPPER(TRIM("Size"))                     AS product_size,
        UPPER(TRIM("SizeUnitMeasureCode"))      AS size_unit_measure_code,
        UPPER(TRIM("WeightUnitMeasureCode"))    AS weight_unit_measure_code,
        CAST("Weight" AS DOUBLE)                AS product_weight,
        CAST("DaysToManufacture" AS INT)        AS days_to_manufacture,
        UPPER(TRIM("ProductLine"))              AS product_line,
        UPPER(TRIM("Class"))                    AS product_class,
        UPPER(TRIM("Style"))                    AS product_style,
        CAST("ProductSubcategoryID" AS INT)     AS product_subcategory_id,
        CAST("SellStartDate" AS TIMESTAMP)      AS sell_start_date,
        CAST("SellEndDate" AS TIMESTAMP)        AS sell_end_date,
        CAST("DiscontinuedDate" AS TIMESTAMP)   AS discontinued_date,
        CAST("ModifiedDate" AS TIMESTAMP)       AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/ProductionProduct.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    product_id,
    product_name,
    product_number,
    make_flag,
    finished_goods_flag,
    color,
    safety_stock_level,
    reorder_point,
    standard_cost,
    list_price,
    product_size,
    CASE
        WHEN product_size IN ('38', '40')           THEN '38-40 Cm'
        WHEN product_size IN ('42', '44', '46')     THEN '42-46 Cm'
        WHEN product_size IN ('48', '50', '52')     THEN '48-52 Cm'
        WHEN product_size IN ('54', '56', '58')     THEN '54-58 Cm'
        WHEN product_size IN ('60', '62')           THEN '60-62 Cm'
        WHEN product_size IN ('S', 'M', 'L', 'XL') THEN product_size
        WHEN product_size IS NULL                   THEN 'NA'
    END                                             AS product_size_range,
    size_unit_measure_code,
    weight_unit_measure_code,
    product_weight,
    days_to_manufacture,
    product_line,
    product_class,
    product_style,
    product_subcategory_id,
    sell_start_date,
    sell_end_date,
    discontinued_date,
    modified_date,
    -- Metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;