from pathlib import Path
import logging
import duckdb


BASE_DIR = Path(__file__).resolve().parent.parent

GOLD_PATH = BASE_DIR / "data" / "gold"
GOLD_SQL_PATH = BASE_DIR / "sql" / "gold"

GOLD_PATH.mkdir(exist_ok=True)


logger = logging.getLogger(__name__)


con = duckdb.connect()

errors = []

def run_gold():
    try:
        for sql_file in sorted(GOLD_SQL_PATH.glob("*.sql")):
            try:
                logger.info(f"Loading {sql_file.name}")

                table_name = sql_file.stem.split("_", 1)[1]
                query = sql_file.read_text(
                    encoding="utf-8"
                ).rstrip(";")

                output_file = GOLD_PATH / f"{table_name}.parquet"

                con.execute(f"""
                    COPY ({query})
                    TO '{output_file}'
                    (FORMAT PARQUET);
                """)

                row_count = con.execute(f"""
                    SELECT COUNT(*) FROM read_parquet('{output_file}')
                """).fetchone()[0]

                logger.info(
                    f"Loaded gold.{table_name}: {row_count} rows"
                )

            except Exception as e:
                logger.error(
                    f"Failed loading {sql_file.name}: {e}",
                    exc_info=True
                )
                errors.append(sql_file.name)

    finally:
        con.close()


    if errors:
        raise RuntimeError(
            f"Loading finished with {len(errors)} errors"
        )