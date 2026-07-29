SELECT
    -1 AS product_category_key,
    -1 AS product_category_alternate_key,
    'UNKNOWN' AS product_category_name,
    'NA' AS _hash,
    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

UNION ALL


SELECT
    ROW_NUMBER() OVER (
        ORDER BY product_category_id
    ) AS product_category_key,

    product_category_id,
    product_category_name,

    unhex(sha256(
        concat_ws('||',
            coalesce(product_category_id, ''),
            coalesce(product_category_name, '')
        )
    )) AS _hash,

    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

FROM read_parquet(
    'data/silver/product_category.parquet'
)