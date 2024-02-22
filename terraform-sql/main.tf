variable project {default = "gcp-bigquery-project1"}
variable region {default = "europe-west3"}
variable name {default = "project1-db"}
variable edition {default = "ENTERPRISE"}
variable database_version {default = "POSTGRES_15"}
variable tier {default = "db-f1-micro"}
variable availability_type {default = "REGIONAL"}
variable db_name {default = "project1"}
variable db_username {default = "project1"}
variable db_password {}
variable deletion_protection {default = "false"}

provider "google" {
  project = var.project
}

resource "google_compute_network" "peering_network" {
  name                    = "private-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "default" {
  name             = var.name
  region           = var.region
  database_version = var.database_version

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.peering_network.id
      # This line is new and neccessary for BigQuery connections
      # Not mentioned in the original documentation
      enable_private_path_for_google_cloud_services = true
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = var.deletion_protection
}

# Create a SQL database within the newly created SQL database instance
resource "google_sql_database" "newdatabase" {
  name       = var.db_name
  instance   = google_sql_database_instance.default.name
}

# Create user for the newly created SQL database instance
resource "google_sql_user" "users" {
  name     = var.db_username
  password = var.db_password
  instance = google_sql_database_instance.default.name
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.peering_network.name
  import_custom_routes = true
  export_custom_routes = true
}

# [START  cloud_sql_postgres_instance_private_ip_dns]

## Uncomment this block after adding a valid DNS suffix

# resource "google_service_networking_peered_dns_domain" "default" {
#   name       = "example-com"
#   network    = google_compute_network.peering_network.id
#   dns_suffix = "example.com."
#   service    = "servicenetworking.googleapis.com"
# }

