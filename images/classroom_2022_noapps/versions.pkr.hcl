packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source  = "github.com/rgl/windows-update"
    }
    git = {
      version = ">= 0.3.2"
      source  = "github.com/ethanmdavidson/git"
    }
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}