# [START google_storage_bucket]


variable project {}
variable name {}
variable location {}


resource "google_storage_bucket" "bigquery_bucket" {
  project             = var.project
  name                = var.name
  location            = var.location
}
# [END google_storage_bucket]
