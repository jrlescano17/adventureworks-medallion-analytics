WITH cleaned AS (
    SELECT
        CAST("TerritoryID" AS INT) AS territory_id,
        TRIM("Name") AS territory_name,
        TRIM("CountryRegionCode") AS country_region_code,
        TRIM("Group") AS territory_group,
        "SalesYTD" AS sales_ytd,
        "SalesLastYear" AS sales_last_year,
        "CostYTD" AS cost_ytd,
        "CostLastYear" AS cost_last_year,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/SalesSalesTerritory.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY territory_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    territory_id,
    territory_name,
    country_region_code,
    territory_group,
    sales_ytd,
    sales_last_year,
    cost_ytd,
    cost_last_year,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;