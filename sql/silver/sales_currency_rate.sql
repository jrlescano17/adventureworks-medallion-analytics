WITH cleaned AS (
    SELECT
        CAST("CurrencyRateID" AS INT) AS currency_rate_id,
        CAST("CurrencyRateDate" AS TIMESTAMP) AS currency_rate_date,
        TRIM("FromCurrencyCode") AS from_currency_code,
        TRIM("ToCurrencyCode") AS to_currency_code,
        "AverageRate" AS average_rate,
        "EndOfDayRate" AS end_of_day_rate,
        CAST("ModifiedDate" AS TIMESTAMP) AS modified_date,
        _ingestion_ts
    FROM read_parquet('data/bronze/SalesCurrencyRate.parquet')
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY currency_rate_id
            ORDER BY modified_date DESC
        ) AS rn
    FROM cleaned
)
SELECT
    currency_rate_id,
    currency_rate_date,
    from_currency_code,
    to_currency_code,
    average_rate,
    end_of_day_rate,
    modified_date,
    --metadata
    _ingestion_ts,
    CURRENT_TIMESTAMP AS _transform_ts
FROM deduplicated
WHERE rn = 1;