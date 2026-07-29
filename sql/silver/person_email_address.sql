WITH cleaned AS (
    SELECT
        CAST("BusinessEntityID" AS INT) AS business_entity_id,
        CAST("EmailAddressID" AS INT) AS email_address_id,
        TRIM("EmailAddress") AS email_address,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/PersonEmailAddress.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY business_entity_id, email_address_id, email_address
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
    WHERE business_entity_id > 0
)
SELECT
    business_entity_id,
    email_address_id,
    email_address,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;