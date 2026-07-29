WITH cleaned AS (
    SELECT
        CAST("AddressID" AS INT) AS address_id,
        TRIM("AddressLine1") AS address_line1,
        TRIM("AddressLine2") AS address_line2,
        TRIM("City") AS city,
        CAST("StateProvinceID" AS INT) AS state_province_id,
        TRIM("PostalCode") AS postal_code,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/PersonAddress.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY address_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    address_id,
    address_line1,
    address_line2,
    city,
    state_province_id,
    postal_code,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;