WITH cleaned AS (
    SELECT
        CAST("SpecialOfferID" AS INT) AS special_offer_id,
        TRIM("Description") AS description,
        "DiscountPct" AS discount_pct,
        TRIM("Type") AS type,
        TRIM("Category") AS category,
        CAST("StartDate" AS DATE) AS start_date,
        CAST("EndDate" AS DATE) AS end_date,
        "MinQty" AS min_qty,
        "MaxQty" AS max_qty,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/SalesSpecialOffer.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY special_offer_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    special_offer_id,
    description,
    discount_pct,
    type,
    category,
    start_date,
    end_date,
    min_qty,
    max_qty,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;