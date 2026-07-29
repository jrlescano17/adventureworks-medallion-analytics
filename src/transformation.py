from pathlib import Path
import logging
import duckdb


BASE_DIR = Path(__file__).resolve().parent.parent

SILVER_PATH = BASE_DIR / "data" / "silver"
SILVER_SQL_PATH = BASE_DIR / "sql" / "silver"

SILVER_PATH.mkdir(exist_ok=True)


logger = logging.getLogger(__name__)


con = duckdb.connect()

errors = []

def run_silver():
    try:
        for sql_file in sorted(SILVER_SQL_PATH.glob("*.sql")):
            try:
                logger.info(f"Transforming {sql_file.name}")

                table_name = sql_file.stem
                query = sql_file.read_text(
                    encoding="utf-8"
                ).rstrip(";")

                output_file = SILVER_PATH / f"{table_name}.parquet"

                con.execute(f"""
                    COPY ({query})
                    TO '{output_file}'
                    (FORMAT PARQUET);
                """)

                row_count = con.execute(f"""
                    SELECT COUNT(*) FROM read_parquet('{output_file}')
                """).fetchone()[0]

                logger.info(
                    f"Loaded silver.{table_name}: {row_count} rows"
                )

            except Exception as e:
                logger.error(
                    f"Failed transforming {sql_file.name}: {e}",
                    exc_info=True
                )
                errors.append(sql_file.name)

    finally:
        con.close()


    if errors:
        raise RuntimeError(
            f"Transformation finished with {len(errors)} errors"
        )