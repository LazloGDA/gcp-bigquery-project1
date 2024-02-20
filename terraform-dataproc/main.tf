# START the Dataproc cluster configuration

variable project {}
variable name {}
variable region {}
variable staging_bucket {}
variable machine_type {}
variable boot_disk_type {}

#resource "google_compute_project_metadata" "default" {
#  metadata = {
#    bigquery-connector-version="1.2.0"
#    spark-bigquery-connector-version="0.21.0"
#    hive-bigquery-connector-version="2.0.3"
#  }
#}

resource "google_dataproc_cluster" "small_cluster" {
  project = var.project
  name    = var.name
  provider = google-beta
  region  = var.region
#  depends_on = [
#    google_compute_project_metadata.default
#  ]  
  
  cluster_config {
    staging_bucket = var.staging_bucket
    
    master_config {
      machine_type = var.machine_type
      disk_config {
        boot_disk_type = var.boot_disk_type
      }
    
    
    }
  
    # Advanced Spark optimizations (without caching)
    software_config {
      optional_components = [ "JUPYTER" ]
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
        "spark:enableAdvancedOptimizations"    = "true"
        "spark:enableAdvancedExecutionLayer"   = "true"
        "spark:enableCaching"                  = "false"
      }
    }
    endpoint_config {
      enable_http_port_access = "true"
    }
    initialization_action {
    script = "gs://goog-dataproc-initialization-actions-europe-west3/connectors/connectors.sh"
    timeout_sec = 500
    }
    gce_cluster_config {
      metadata = {
        bigquery-connector-version="1.2.0"
        spark-bigquery-connector-version="0.21.0"
        hive-bigquery-connector-version="2.0.3"
      }
    }

  }
}

# END the Dataproc cluster configuration
