WITH cleaned AS (
    SELECT
        CAST("ProductSubcategoryID" AS INT) AS product_subcategory_id,
        CAST("ProductCategoryID" AS INT) AS product_category_id,
        TRIM("Name") AS product_subcategory_name,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/ProductionProductSubcategory.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_subcategory_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    product_subcategory_id,
    product_category_id,
    product_subcategory_name,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;