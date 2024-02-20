# NOT TESTED YET

# [START cloud_sql_instance]
variable deletion_protection {}
variable project {}
variable name {}
variable edition {}
variable region {}
variable database_version {}
#variable root_password {}
variable tier {}
variable availability_type {}
variable db_name {}
variable db_username {}
variable db_user_password {}


resource "google_sql_database_instance" "postgres" {
  project             = var.project
  name                = var.name
  region              = var.region
  database_version    = var.database_version
#  root_password       = var.root_password
  settings {
    tier              = var.tier
    edition           = var.edition
    availability_type = var.availability_type
  }
  deletion_protection = var.deletion_protection
}
# [END cloud_sql_instance]

# Create a SQL database within the newly created SQL database instance
resource "google_sql_database" "newdatabase" {
  name       = var.db_name
  instance   = google_sql_database_instance.postgres.name
  project    = var.project
}

# Create user for the newly created SQL database instance
resource "google_sql_user" "users" {
  name     = var.db_username
  password = var.db_user_password
  instance = google_sql_database_instance.postgres.name
}