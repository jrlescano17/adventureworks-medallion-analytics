WITH cleaned AS (
    SELECT
        CAST("ProductID" AS INT) AS product_id,
        CAST("StartDate" AS TIMESTAMP) AS start_date,
        CAST("EndDate" AS TIMESTAMP) AS end_date,
        CAST("StandardCost" AS DOUBLE) AS standard_cost,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/ProductionProductCostHistory.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id, start_date
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    product_id,
    start_date,
    end_date,
    standard_cost,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;