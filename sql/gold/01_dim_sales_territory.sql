SELECT
    -1 AS territory_key,
    -1 AS territory_alternate_key,
    'UNKNOWN' AS territory_name,
    'UNKNOWN' AS country_region_name,
    'UNKNOWN' AS territory_group,
    NULL AS _hash,
    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

UNION ALL

SELECT
    ROW_NUMBER() OVER (
        ORDER BY territory_id
    ) AS territory_key,

    a.territory_id,
    a.territory_name,
    b.country_region_name,
    a.territory_group,

    unhex(sha256(
        concat_ws('||',
            COALESCE(a.territory_name, ''),
            COALESCE(b.country_region_name, ''),
            COALESCE(a.territory_group, '')
        )
    )) AS _hash,

    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

FROM read_parquet('data/silver/sales_territory.parquet') a
LEFT JOIN read_parquet('data/silver/person_country_region.parquet') b
    ON a.country_region_code = b.country_region_code;