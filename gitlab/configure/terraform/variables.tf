variable "token" {
  description = "Authentication token for the gitlab administrator profile"
}

variable "sonar_token" {
  description = "Authentication token for the sonarqube administrator"
}

variable "sonar_keystore_pw" {
  description = "Password for the keystore with the certificate sonar needs for ssl"
}

variable "groups" {
  description = "Groups to create"
}

variable "projects" {
  description = "Projects to create"
}

variable "variables" {
  description = "Group variables for projects to inherit"
}