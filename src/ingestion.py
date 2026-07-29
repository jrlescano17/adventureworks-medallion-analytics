from pathlib import Path
import logging
import duckdb

# Configuración de paths
BASE_DIR = Path(__file__).resolve().parent.parent

RAW_PATH = BASE_DIR / "data" / "raw"
BRONZE_PATH = BASE_DIR / "data" / "bronze"

BRONZE_PATH.mkdir(exist_ok=True)


logger = logging.getLogger(__name__)

con = duckdb.connect()

errors = []

def run_ingestion():
    try:
        for file in RAW_PATH.glob("*.csv"):
            try:
                logger.info(f"Loading {file.name}")

                archivo = file.stem
                output_file = BRONZE_PATH / f"{archivo}.parquet"

                con.execute(f"""
                    COPY (
                        SELECT
                            *,
                            CURRENT_TIMESTAMP AS _ingestion_ts,
                            '{file.name}' AS _source_file
                        FROM read_csv_auto(
                            '{file.as_posix()}',
                            ALL_VARCHAR=TRUE
                        )
                    )
                    TO '{output_file.as_posix()}'
                    (FORMAT PARQUET);
                """)

                row_count = con.execute(f"""
                    SELECT COUNT(*)
                    FROM read_parquet('{output_file.as_posix()}')
                """).fetchone()[0]

                logger.info(
                    f"Loaded {row_count} rows from {file.name}"
                )

            except Exception as e:
                logger.error(
                    f"Failed loading {file.name}: {e}",
                    exc_info=True
                )
                errors.append(file.name)

    finally:
        con.close()

    if errors:
        raise RuntimeError(
            f"Failed transformations: {errors}"
        )