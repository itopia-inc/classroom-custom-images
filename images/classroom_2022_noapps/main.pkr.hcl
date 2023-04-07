############################################
##              Datasources               ##
############################################

data "git-commit" "cwd-head" {}
data "git-repository" "cwd" {}

data "hcp-packer-image" "labs-windows-2022-base" {
  bucket_name    = var.source_image_family
  cloud_provider = "gce"
  region         = var.zone
  channel        = var.environment
}

############################################
## No Apps Image  -   Windows Server 2022 ##
############################################

source "googlecompute" "classroom_2022_noapps" {
  accelerator_count = var.accelerator_count
  accelerator_type  = "projects/${var.project_id}/zones/${var.zone}/acceleratorTypes/${var.gpu_type}"
  communicator      = var.communicator
  instance_name     = "packer-${var.image_name}-${local.truncated_sha}-${local.timestamp}"
  disk_type         = var.disk_type
  disk_size         = var.disk_size
  image_name        = "${var.image_name}-${local.builddate}"
  machine_type      = var.machine_type
  state_timeout     = var.state_timeout
  metadata = {
    windows-shutdown-script-ps1 = "Enable-LocalUser -Name \"student\""
    windows-startup-script-cmd  = "winrm quickconfig -quiet & net user /add packer_user & net localgroup administrators packer_user /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
  }
  on_host_maintenance         = var.on_host_maintenance
  project_id                  = var.project_id
  source_image                = var.custom_source_image != "" ? var.custom_source_image : data.hcp-packer-image.labs-windows-2022-base.id
  winrm_insecure              = true
  winrm_use_ssl               = true
  winrm_username              = var.winrm_username
  zone                        = var.zone
  network                     = var.network
  subnetwork                  = "${var.network}-${substr(var.zone, 0, length(var.zone) - 2)}"
  image_licenses              = var.asm_images_licenses_url
  image_family                = var.promote_image ? var.image_family_name : null
  use_iap                     = true
  impersonate_service_account = "packer@${var.project_id}.iam.gserviceaccount.com"

  image_labels = {
    environment          = var.environment
    parent-image-name    = data.hcp-packer-image.labs-windows-2022-base.id
    parent-image-family  = var.source_image_family
    parent-image-project = var.project_id
    commit-id            = data.git-commit.cwd-head.hash
  }
}

build {
  # HCP Packer Registry requires environment variables HCP_CLIENT_ID and HCP_CLIENT_SECRET to be set
  hcp_packer_registry {
    bucket_name = var.image_name
    description = <<EOT
    No Apps image for Windows Server 2022
    EOT
    bucket_labels = {
      "os"         = "Windows",
      "os_version" = "2022",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = ["source.googlecompute.classroom_2022_noapps"]

  
  provisioner "powershell" {
    script = "./images/scripts/install/example.ps1"
  }


  ############################################
  ##             Post Processors            ##
  ############################################

  post-processors {
    post-processor "manifest" {
      output     = "manifest.json"
      strip_path = true
      custom_data = {
        iteration   = "${packer.iterationID}"
        bucket_name = "${var.image_name}"
      }
    }
    post-processor "shell-local" {
      inline = ["cat manifest.json"]
    }
  }
}