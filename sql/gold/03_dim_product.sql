SELECT
    -1 AS product_key,
    '-1' AS product_alternate_key,
    -1 AS product_subcategory_key,
    'UNKNOWN' AS product_name,
    'UNKNOWN' AS product_model,
    'UNKNOWN' AS description,
    NULL AS weight_unit_measure_code,
    NULL AS size_unit_measure_code,
    NULL AS finished_goods_flag,
    NULL AS color,
    NULL AS safety_stock_level,
    NULL AS reorder_point,
    NULL AS product_size,
    NULL AS product_size_range,
    NULL AS product_weight,
    NULL AS days_to_manufacture,
    NULL AS product_line,
    NULL AS product_class,
    NULL AS product_style,
    NULL AS _hash,
    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

UNION ALL

SELECT
    ROW_NUMBER() OVER (
        ORDER BY product_number
    ) AS product_key,

    p.product_number,
    COALESCE(s.product_subcategory_key, -1)  AS product_subcategory_key,
    p.product_name,
    pd.product_model,
    pd.description,
    p.weight_unit_measure_code,
    p.size_unit_measure_code,
    p.finished_goods_flag,
    p.color,
    p.safety_stock_level,
    p.reorder_point,
    p.product_size,
    p.product_size_range,
    p.product_weight,
    p.days_to_manufacture,
    p.product_line,
    p.product_class,
    p.product_style,

    unhex(sha256(
        concat_ws('||',
            CAST(COALESCE(s.product_subcategory_key, -1) AS VARCHAR),
            COALESCE(p.product_name, ''),
            COALESCE(pd.product_model, ''),
            COALESCE(pd.description, ''),
            COALESCE(p.weight_unit_measure_code, ''),
            COALESCE(p.size_unit_measure_code, ''),
            CAST(COALESCE(p.finished_goods_flag, FALSE) AS VARCHAR),
            COALESCE(p.color, ''),
            CAST(COALESCE(p.safety_stock_level, 0) AS VARCHAR),
            CAST(COALESCE(p.reorder_point, 0) AS VARCHAR),
            COALESCE(p.product_size, ''),
            COALESCE(p.product_size_range, ''),
            CAST(COALESCE(p.product_weight, 0) AS VARCHAR),
            CAST(COALESCE(p.days_to_manufacture, 0) AS VARCHAR),
            COALESCE(p.product_line, ''),
            COALESCE(p.product_class, ''),
            COALESCE(p.product_style, '')
        )
    )) AS _hash,

    CURRENT_TIMESTAMP AS _insert_ts,
    CURRENT_TIMESTAMP AS _update_ts

FROM read_parquet('data/silver/production_product.parquet') p
LEFT JOIN read_parquet('data/silver/production_product_and_description.parquet') pd
    ON p.product_id = pd.product_id AND UPPER(pd.culture_id) = 'EN'
LEFT JOIN read_parquet('data/gold/dim_product_subcategory.parquet') s
    ON p.product_subcategory_id = s.product_subcategory_alternate_key;