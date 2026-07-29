WITH cleaned AS (
    SELECT
        CAST("BusinessEntityID" AS INT) AS business_entity_id,
        CAST("BirthDate" AS DATE) AS birth_date,
        UPPER(TRIM("MaritalStatus")) AS marital_status,
        TRIM("YearlyIncome") AS yearly_income,
        UPPER(TRIM("Gender")) AS gender,
        CAST("TotalChildren" AS INT) AS total_children,
        CAST("NumberChildrenAtHome" AS INT) AS number_children_at_home,
        UPPER(TRIM("Education")) AS education,
        UPPER(TRIM("Occupation")) AS occupation,
        CAST("HomeOwnerFlag" AS BOOLEAN) AS home_owner_flag,
        CAST("NumberCarsOwned" AS INT) AS number_cars_owned,
        _ingestion_ts
    FROM read_parquet('data/bronze/SalesvPersonDemographics.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY business_entity_id
            ORDER BY business_entity_id
        ) AS rn
    FROM cleaned
    WHERE business_entity_id > 0
)
SELECT
    business_entity_id,
    birth_date,
    marital_status,
    yearly_income,
    gender,
    total_children,
    number_children_at_home,
    education,
    occupation,
    home_owner_flag,
    number_cars_owned,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;