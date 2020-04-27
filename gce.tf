resource "google_compute_instance" "vm_instance" {
  name = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  //metadata_startup_script = "sudo apt-get update"

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    sshKeys = "ubuntu:${file("~/.ssh/gcp.pub")}"
  }
}

resource "google_compute_firewall" "default" {
  name = "nginx-app-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22","80","443","8080"]
  }
}

resource "null_resource" "example_provisioner" {
  triggers = {
    //build_number = timestamp()
    public_ip = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y letsencrypt git",
      "git clone https://github.com/shdkej/environment",
      "sudo sh environment/docker.sh",
      "sudo letsencrypt certonly --standalone -d shdkej.com -m shdkej@gmail.com -n --agree-tos",
      "git clone https://github.com/shdkej/docker",
      "sudo docker-compose -f docker/nginx/docker-compose.yml up -d"
    ]
  }

  connection {
    host = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/gcp")
  }
}

output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
