WITH cleaned AS (
    SELECT
        UPPER(TRIM("CurrencyCode")) AS currency_code,
        UPPER(TRIM("Name")) AS currency_name,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/SalesCurrency.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY currency_code
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    currency_code,
    currency_name,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;