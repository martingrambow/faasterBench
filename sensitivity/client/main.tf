provider "google" {
  project = var.project
  region  = var.region
}

resource "google_compute_network" "my_network" {
  name = "my-network"
}

resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.my_network.self_link
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-htgtps"
  network = google_compute_network.my_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "client" {
  name         = "benchmark-client"
  machine_type = "e2-standard-4"
  zone         = "europe-west3-c"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.my_network.self_link
    access_config {}
  }
  metadata = {
    system-under-test = "faasterbench-client"
    ssh-keys = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}"
  }
   metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # Install gcloud
    echo "Installing Google Cloud SDK (gcloud)..."
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk

    # Install aws-cli
    echo "Installing AWS Command Line Interface (aws-cli)..."
    sudo apt-get install -y awscli

    # Install az (Azure CLI)
    echo "Installing Azure CLI (az)..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    # Install npm and node
    nvm install node

    # Install artillery
    npm install -g artillery
  EOF

}