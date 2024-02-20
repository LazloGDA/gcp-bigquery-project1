# Enable required APIs

variable project {}

resource "google_project_service" "dataproc" {
  project = var.project
  service = "dataprocessing.googleapis.com"
}

resource "google_project_service" "bigquery" {
  project = var.project
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "cloudsql" {
  project = var.project
  service = "sql-component.googleapis.com"
}

resource "google_project_service" "storage" {
  project = var.project
  service = "storage.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}