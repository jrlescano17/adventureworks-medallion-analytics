WITH cleaned AS (
    SELECT
        CAST("BusinessEntityID" AS INT) AS business_entity_id,
        TRIM("PhoneNumber") AS phone_number,
        CAST("PhoneNumberTypeID" AS INT) AS phone_number_type_id,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts,
        -- Normalización para deduplicación: solo dígitos
        REGEXP_REPLACE("PhoneNumber", '[^0-9]', '') AS phone_number_digits
    FROM read_parquet('data/bronze/PersonPersonPhone.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY business_entity_id, phone_number_digits, phone_number_type_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
    WHERE business_entity_id > 0
)
SELECT
    business_entity_id,
    phone_number,
    phone_number_type_id,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;