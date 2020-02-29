#
# main.tf - GKE Cluster for Spark Demo
# 

provider "google" {
  region 	= var.region
  project	= var.project
}

provider "google-beta" {
  region 	= var.region
  project	= var.project
}

resource "google_container_cluster" "spark_cluster" {
  provider           = google-beta
  name               = "spark-cluster"
  location           = var.zone
  project            = var.project
  initial_node_count = var.initial_node_count
  #default_max_pods_per_node = 110
  network            = "private-network"
  subnetwork         = "regional-subnet"

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    image_type = "COS"
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}

