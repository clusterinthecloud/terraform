# Pin the terraform and provider versions to avoid issues if the 

terraform             {required_version = "0.11.13"}
provider "template"   {version = "2.1"}
provider "external"   {version = "1.2"}
provider "local"      {version = "1.3"}

provider "google" {
  version = "2.10"
  credentials = "${file(var.credentials)}"
  region  = "${var.region}"
  zone    = "${var.zone}"
  project = "${var.project}"
}
