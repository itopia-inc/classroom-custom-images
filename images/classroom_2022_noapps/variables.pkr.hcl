#################################Locals#######################################
locals {
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  builddate     = formatdate("YYYYMMDDHHmmss", timestamp())
  truncated_sha = substr(data.git-commit.cwd-head.hash, 0, 8)
}

variable "environment" {
  type        = string
  description = "The environment to deploy into"
  default     = "dev"
}

variable "image_name" {
  description = "The name of the image to be created"
  default     = "classroom-windows-2022-noapps"
}

variable "accelerator_count" {
  description = "Number of accelerators to attach to each instance"
  default     = 0
}

variable "project_id" {
  description = "The ID of the project in which the resources will be created"
}

variable "zone" {
  description = "The zone that the instance should be created in"
  default     = "us-central1-b"
}

variable "machine_type" {
  description = "The machine type to use for the instance"
  default     = "n1-standard-4"
}

variable "image_family_name" {
  description = "The image family to use for the instance"
  default     = "classroom-windows-2022-noapps"
}

variable "gpu_type" {
  description = "The type of GPU to attach to the instance"
  default     = "nvidia-tesla-t4"
}

variable "communicator" {
  description = "The communicator to use for the instance"
  default     = "winrm"
}

variable "winrm_username" {
  description = "The username to use for the winrm communicator"
  default     = "packer_user"
}

variable "on_host_maintenance" {
  description = "The behavior to use when a host machine undergoes maintenance"
  default     = "TERMINATE"
}

variable "disk_type" {
  description = "The type of disk to use for the instance"
  default     = "pd-ssd"
}

variable "disk_size" {
  description = "The size of the disk to use for the instance"
  default     = "100"
}

variable "source_image_family" {
  description = "The source image family to use for the image"
  default     = "labs-windows-2022-base"
}

variable "network" {
  description = "The network to use for the instance"
  default     = "project-network"
}

variable "asm_images_licenses_url" {
  description = "The URL to the ASM images license"
}

variable "default_user_password" {
  description = "The default password to use for the instance"
}

variable "state_timeout" {
  description = "The time to wait for instance state changes"
  default     = "15m"
}

variable "promote_image" {
  description = "Whether to promote the image to the image family"
  default     = false
}

variable "custom_source_image" {
  description = "Custom Source Image"
  default     = ""
}