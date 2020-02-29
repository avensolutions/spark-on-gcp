#
# main.tf - Private network for Spark demo
# 

provider "google" {
  region 	= var.region
  project	= var.project
}

# create a custom VPC
resource "google_compute_network" "private_network" {
  name = "private-network"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}

# create a regional subnet
resource "google_compute_subnetwork" "regional_subnet" {
  name          = "regional-subnet"
  ip_cidr_range = var.primary_ip_range
  region        = var.region
  network       = google_compute_network.private_network.self_link
  secondary_ip_range {
    range_name    = "secondary-range"
    ip_cidr_range = var.secondary_ip_range
  }
  private_ip_google_access = true
}

# create FW rules for internal traffic
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.private_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }  

  source_ranges = [var.primary_ip_range, var.secondary_ip_range]
}

# create FW rule for RDP
resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"
  network = google_compute_network.private_network.name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# create FW rule for IAP
resource "google_compute_firewall" "allow_iap_tcp_forwarding" {
  name    = "allow-iap-tcp-forwarding"
  network = google_compute_network.private_network.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

# create FW rule for Health Checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = google_compute_network.private_network.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16","130.211.0.0/22"]

  target_tags = ["allow-health-checks"]
}