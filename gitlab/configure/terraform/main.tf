# https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group
resource "gitlab_group" "groups" {
  count = "${length(var.groups)}"

  name        = var.groups["${count.index}"].name
  path        = var.groups["${count.index}"].path
  description = var.groups["${count.index}"].description
  avatar = var.groups["${count.index}"].avatar

  # https://docs.gitlab.com/ee/api/groups.html#options-for-default_branch_protection
  default_branch_protection = 1
  # extra_shared_runners_minutes_limit = 10 # justification for using the administrator for all of this
  require_two_factor_authentication = false
  visibility_level = "public"
}

# resource "gitlab_topic" "topics" {
#   count = "${length(distinct(flatten(var.projects[*].topics)))}"
#   name = distinct(flatten(var.projects[*].topics))["${count.index}"]
#   title = distinct(flatten(var.projects[*].topics))["${count.index}"]
# }



# https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project
resource "gitlab_project" "projects" {
  count = "${length(var.projects)}"

  name = var.projects["${count.index}"].name
  description = var.projects["${count.index}"].description
  avatar = var.projects["${count.index}"].avatar
  namespace_id = gitlab_group.groups[
    index(var.groups[*].name, var.projects["${count.index}"].group_name)
  ].id
  
  # tags = [""], supuestamente mejor topics
  topics = var.projects["${count.index}"].topics
  allow_merge_on_skipped_pipeline = false
  archive_on_destroy = false
  environments_access_level = "enabled"
  initialize_with_readme = false
  releases_access_level = "enabled"
  visibility_level = "public"

  container_expiration_policy {
    cadence = "7d"
    enabled = true
    # keep_n = "3"
  }

  # push_rules {
  #   branch_name_regex = "(feature|hotfix|dev|master)\\/*"
  #   commit_committer_check = false
  #   # prevent_secrets = true
  # }
}

