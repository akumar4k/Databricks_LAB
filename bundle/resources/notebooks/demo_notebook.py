# Databricks notebook source
dbutils.widgets.text("input", "world")
name = dbutils.widgets.get("input")

print(f"Hello, {name} from the Databricks DevOps lab (DAB)!")

from pyspark.sql import Row

data = [Row(id=1, event="lab_started"), Row(id=2, event="lab_completed")]
df = spark.createDataFrame(data)

catalog = "<REPLACE_WITH_CATALOG>"
schema = "<REPLACE_WITH_SCHEMA>"
table = f"{catalog}.{schema}.lab_events"

print(f"Writing sample data to {table}")
df.write.mode("overwrite").saveAsTable(table)

display(spark.table(table))
