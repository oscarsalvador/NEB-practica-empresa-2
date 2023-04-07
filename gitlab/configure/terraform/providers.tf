# https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/guides/version-15.7-upgrade
terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "15.10.0"
      # version = "3.5.0"
    }
  }
}

provider "gitlab" {
  base_url   = "https://gitlab.gitlab.local"
  token = var.token
  insecure = true
}