WITH cleaned AS (
    SELECT
        CAST("StateProvinceID" AS INT) AS state_province_id,
        TRIM("StateProvinceCode") AS state_province_code,
        TRIM("CountryRegionCode") AS country_region_code,
        "IsOnlyStateProvinceFlag" AS is_only_state_province_flag,
        TRIM("Name") AS state_province_name,
        CAST("TerritoryID" AS INT) AS territory_id,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/PersonStateProvince.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY state_province_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    state_province_id,
    state_province_code,
    country_region_code,
    is_only_state_province_flag,
    state_province_name,
    territory_id,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;