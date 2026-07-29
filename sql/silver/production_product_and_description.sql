WITH cleaned AS (
    SELECT
        CAST("ProductID" AS INT) AS product_id,
        UPPER(TRIM("Name")) AS product_name,
        UPPER(TRIM("ProductModel")) AS product_model,
        UPPER(TRIM("CultureID")) AS culture_id,
        TRIM("Description") AS description,
        _ingestion_ts
    FROM read_parquet('data/bronze/ProductionvProductAndDescription.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY product_id
        ) AS rn
    FROM cleaned
    WHERE product_id > 0 AND culture_id = 'EN'
)
SELECT
    product_id,
    product_name,
    product_model,
    description,
    culture_id,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;