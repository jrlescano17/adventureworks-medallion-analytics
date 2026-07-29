WITH cleaned AS (
    SELECT
        CAST("BusinessEntityID" AS INT) AS business_entity_id,
        TRIM("PersonType") AS person_type,
        CAST("NameStyle" AS BOOLEAN) AS name_style,
        NULLIF(TRIM("Title"), '') AS title,
        NULLIF(TRIM("FirstName"), '') AS first_name,
        NULLIF(TRIM("MiddleName"), '') AS middle_name,
        NULLIF(TRIM("LastName"), '') AS last_name,
        NULLIF(TRIM("Suffix"), '') AS suffix,
        CAST("EmailPromotion" AS INT) AS email_promotion,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/PersonPerson.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY business_entity_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    business_entity_id,
    person_type,
    name_style,
    title,
    first_name,
    middle_name,
    last_name,
    suffix,
    email_promotion,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;