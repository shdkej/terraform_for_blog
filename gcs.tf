resource "google_storage_bucket" "my_bucket" {
  name = "my_bucket_for_terraform"
  location = "us-west1"
}

terraform {
  backend "gcs" {
    bucket = "shdkej-tfstate-bucket"
    prefix = "first-app"
    credentials = "~/workspace/file/my-project-2f0a7531d956.json"
  }
}
