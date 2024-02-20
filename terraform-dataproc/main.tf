# START the Dataproc cluster configuration

variable project {}
variable name {}
variable region {}
variable staging_bucket {}
variable machine_type {}
variable boot_disk_type {}

resource "google_dataproc_cluster" "small_cluster" {
  project = var.project
  name    = var.name
  region  = var.region
  
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
    }
}

# END the Dataproc cluster configuration
