# -*- coding: utf-8 -*-
"""notebooks_jupyter_Test_Data_transformation.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/16fLvvp0nGxsau5I_TaGLVvlWGaqgclng
"""

from pyspark.sql import SparkSession
import matplotlib.pyplot as plt
from sklearn import metrics
from sklearn.preprocessing import StandardScaler
from matplotlib.lines import Line2D
from matplotlib import cm
import numpy as np
import pandas as pd
import seaborn as sns

from pyspark.ml import Pipeline
from pyspark.ml.feature import StringIndexer, VectorAssembler, OneHotEncoder
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from pyspark.ml.tuning import ParamGridBuilder, CrossValidator

import warnings
warnings.filterwarnings("ignore")

spark = SparkSession.builder.appName("FlightStatus_test").getOrCreate()

#spark = SparkSession.builder \
#    .appName('FlightStatus') \
#    .config('spark.jars.packages', 'com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.23.2') \
#    .getOrCreate()

path = "gs://gcp-bigquery-project1-bucket/data/Combined_Flights_2022.csv"

df = spark.read.csv(path, header=True, inferSchema=True, sep=",")

df.show()

df.count()

from pyspark.sql.functions import col

# Create a filter condition for null values in any column
null_filter = " | ".join([f"col('{c}').isNull()" for c in df.columns])

rows_with_null = df.filter(eval(null_filter))

rows_with_null.show(100)

rows_with_null.count()

# Create a filter condition for null values in any column, considering only rows where 'Cancelled' is true
null_filter = " | ".join([f"col('{c}').isNull()" for c in df.columns if c != "Cancelled"])
full_filter = f"(col('Cancelled') == True) & ({null_filter})"

rows_with_null_when_cancelled = df.filter(eval(full_filter))

rows_with_null_when_cancelled.count()

rows_with_null.count()-rows_with_null_when_cancelled.count()

# Create a filter condition for null values in any column, considering only rows where 'Cancelled' and 'Diverted' are false
null_filter = " | ".join([f"col('{c}').isNull()" for c in df.columns if c not in ["Cancelled", "Diverted"]])
full_filter = f"(col('Cancelled') == False) & (col('Diverted') == False) & ({null_filter})"


rows_with_null_when_not_cancelled_or_diverted = df.filter(eval(full_filter))

rows_with_null_when_not_cancelled_or_diverted.count()

# Create a filter condition for null values in any column, considering only rows where 'Cancelled' is false and 'Diverted' is true
null_filter = " | ".join([f"col('{c}').isNull()" for c in df.columns if c not in ["Cancelled", "Diverted"]])
full_filter = f"(col('Cancelled') == False) & (col('Diverted') == True) & ({null_filter})"


rows_with_null_when_not_cancelled_but_diverted = df.filter(eval(full_filter))

rows_with_null_when_not_cancelled_but_diverted.count()

"""Conclusion:
if the flight is cancelled, there is no departure or arrival related data --> NULL

if the flight is diverted, there is no arrival related data.
"""

cols_with_null = [c for c in df.columns if df.filter(col(c).isNull()).count() > 0]

df_clean = df.drop(*cols_with_null)

df_clean.columns

columns_to_remove = ['OriginState', 'OriginStateName', 'DestState', 'DestStateName', 'IATA_Code_Marketing_Airline', 'IATA_Code_Operating_Airline', 'OriginAirportSeqID', 'DestAirportSeqID']

df_clean = df_clean.drop(*columns_to_remove)

project_id = "gcp-bigquery-project1"
dataset_id = "test_flight_status"
table_id = "flight_status_table"

table_ref = f"{project_id}:{dataset_id}.{table_id}"

table_ref

#df_clean.write \
 # .format("com.google.cloud.spark.bigquery") \
 # .option("temporaryGcsBucket","gcp-bigquery-project1-bucket") \
 # .option("table", table_ref) \
 # .mode("overwrite") \
 # .save()

df_clean.write \
  .format("bigquery") \
  .option("temporaryGcsBucket","gcp-bigquery-project1-bucket") \
  .option("table", table_ref) \
  .mode("overwrite") \
  .save()

