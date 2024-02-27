#!/bin/bash

# Important remark:
# This script copy the BigQuery models into a broject buckets
# and download the project buckets into this repo folder.
# But currently you have to download manually the BigQuery "saved_query" contents. 


# copy the BigQuery models into a broject buckets
# It needs to adjust if you have new models in BigQuery
bq extract -m flight_status.XGB_1 gs://gcp-bigquery-project1-bucket/bigquery/models/XGB_1_model
bq extract -m flight_status.logistic_model_1 gs://gcp-bigquery-project1-bucket/bigquery/models/logistic_model_1
bq extract -m flight_status.logistic_model_2 gs://gcp-bigquery-project1-bucket/bigquery/models/logistic_model_2

# Download the project bucket folders
# It needs to adjust if you have new buckets in the project
gsutil -m cp -r \
  "gs://gcp-bigquery-project1-bucket/google-cloud-dataproc-metainfo" \
  "gs://gcp-bigquery-project1-bucket/notebooks" \
  "gs://gcp-bigquery-project1-bucket/python" \
  "gs://gcp-bigquery-project1-bucket/bigquery" \
  .
