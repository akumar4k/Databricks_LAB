dbutils.widgets.text("input", "world")
dbutils.widgets.text("catalog", "main")
dbutils.widgets.text("schema", "devops_lab")

name = dbutils.widgets.get("input")
catalog = dbutils.widgets.get("catalog")
schema = dbutils.widgets.get("schema")

print(f"Hello, {name} from the Databricks DevOps lab!")

from pyspark.sql import Row

data = [Row(id=1, event="lab_started"), Row(id=2, event="lab_completed")]
df = spark.createDataFrame(data)

table = f"{catalog}.{schema}.lab_events"

print(f"Writing sample data to {table}")
df.write.mode("overwrite").saveAsTable(table)

display(spark.table(table))

