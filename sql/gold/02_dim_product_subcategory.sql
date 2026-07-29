SELECT
    -1 AS product_subcategory_key,
    -1 AS product_subcategory_alternate_key,
    'UNKNOWN' AS product_subcategory_name,
    -1 AS product_category_key,
    'NA' AS _hash,
    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

UNION ALL

SELECT
    ROW_NUMBER() OVER (
        ORDER BY product_subcategory_id
    ) AS product_subcategory_key,


    a.product_subcategory_id,
    a.product_subcategory_name,
    COALESCE(b.product_category_key, -1) AS product_category_key,

    unhex(sha256(
        concat_ws('||',
            coalesce(a.product_subcategory_name, ''),
            CAST(COALESCE(a.product_category_id, -1) AS VARCHAR)
        )
    )) AS _hash,

    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

FROM read_parquet('data/silver/product_subcategory.parquet') a
LEFT JOIN read_parquet('data/gold/dim_product_category.parquet') b
    ON a.product_category_id = b.product_category_alternate_key;