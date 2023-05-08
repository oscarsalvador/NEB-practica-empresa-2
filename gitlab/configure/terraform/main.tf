locals {
  code_projects = flatten([
    for i in gitlab_project.projects: 
      [
        {
          project = i
          branch = "master"
          # push_access_level = "no one"
          push_access_level = "maintainer"
          merge_access_level = "maintainer"
        },
        {
          project = i
          branch = "develop"
          push_access_level = "maintainer"
          merge_access_level = "developer"
        }
      ] if length(regexall("code", i.name)) > 0
  ])
  infra_projects = flatten([
    for i in gitlab_project.projects: 
      [
        {
          project = i
          branch = "production"
          # push_access_level = "no one"
          push_access_level = "maintainer"
          merge_access_level = "maintainer"
        },
        {
          project = i
          branch = "preproduction"
          push_access_level = "maintainer"
          merge_access_level = "maintainer"
        }
      ] if length(regexall("infra", i.name)) > 0
  ])
  envs = distinct(flatten([
    for project in var.projects: [
      for env in project.environments: {
        project = project.name
        environment = env
      }
    ]
  ]))
  users = [for i in values(gitlab_user.users) : {
    name = i.name
    id = i.id
  }]
  memberships = distinct(flatten([
    for project in var.projects: [
      for member in project.members: {
        project = project.name
        username = member.name
        access = member.access
      }
    ]
  ]))
  vars = distinct(flatten([
    for variable in var.variables: [
      for group in variable.groups : [
        for env in variable.environment_scope: {
          group = group
          key = variable.key
          value = variable.value
          protected = variable.protected
          masked = variable.protected
          environment_scope = env
        }
      ]
    ]
  ]))
}

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




resource "gitlab_branch_protection" "code_branch_protections"{
  count = "${length(local.code_projects)}"
  project = local.code_projects["${count.index}"].project.id
  branch = local.code_projects["${count.index}"].branch
  push_access_level = local.code_projects["${count.index}"].push_access_level
  merge_access_level = local.code_projects["${count.index}"].merge_access_level
}

resource "gitlab_branch_protection" "infra_branch_protections" {
  count = "${length(local.infra_projects)}"
  project = local.infra_projects["${count.index}"].project.id
  branch = local.infra_projects["${count.index}"].branch
  push_access_level = local.infra_projects["${count.index}"].push_access_level
  merge_access_level = local.infra_projects["${count.index}"].merge_access_level
}





resource "random_string" "pw" {
  length = 10
  special = false
  upper = false
}
# for this demo, I take the list of users to create from the users mentioned in the list of projects
resource "gitlab_user" "users" {
  # for_each = toset(["developer1", "developer2", "maintainer1"])
  for_each = {for i in distinct([
      for membership in local.memberships: {
        name = membership.username
      }
    ]): "${i.name}" => i
  }

  name = each.key
  username = each.key
  password = "${random_string.pw.result}"
  email = "${each.key}@example.com"
  is_admin = false
  # reset_password = false # for this demo, would complicate the scripted simulation
}


resource "gitlab_project_membership" "memberships" {
  # for_each = {
  #   for i in gitlab_project.projects: i.id => i
  #     if length(regexall("code", i.name)) > 0
  # }
  count = "${length(local.memberships)}"

  project_id = gitlab_project.projects[
    index(gitlab_project.projects[*].name, local.memberships["${count.index}"].project)
  ].id
  user_id = local.users[
    # index(values(gitlab_user.users[*].name), local.memberships["${count.index}"].username)
    index(local.users[*].name, local.memberships["${count.index}"].username)
  ].id
  # user_id = gitlab_user.users[
  #   index(gitlab_user.users[*].name, "developer1")
  # ].id
  access_level = local.memberships["${count.index}"].access

  depends_on = [
    gitlab_user.users
  ]
}




resource "gitlab_project_environment" "environments" {
  for_each = { for i in local.envs: "${i.project}.${i.environment}" => i}

  project = gitlab_project.projects[
    index(gitlab_project.projects[*].name, each.value.project)
  ].id
  name = each.value.environment
  stop_before_destroy = true
}
# resource "gitlab_project_environment" "environments" {
#   project = gitlab_project.projects[0].id
#   name = "pre"
# }





resource "gitlab_group_variable" "variables" {
  count = "${length(local.vars)}"

  group = gitlab_group.groups[
    index(gitlab_group.groups[*].name, local.vars["${count.index}"].group)
  ].id
  key = local.vars["${count.index}"].key
  value = ( local.vars["${count.index}"].environment_scope == "pre" ? 
    "pre${local.vars["${count.index}"].value}" :
    "${local.vars["${count.index}"].value}" )
  protected = local.vars["${count.index}"].protected
  masked = local.vars["${count.index}"].masked
  environment_scope = local.vars["${count.index}"].environment_scope

  depends_on = [
    gitlab_group.groups
  ]
}

resource "gitlab_group_variable" "sonar" {
  group = gitlab_group.groups[
    index(gitlab_group.groups[*].name, "application-repos")
  ].id
  key = "SONAR_TOKEN"
  value = var.sonar_token
  protected = false
  masked = false
  environment_scope = "*"

  depends_on = [
    gitlab_group.groups
  ]
}

resource "gitlab_group_variable" "sonar_truststore" {
  group = gitlab_group.groups[
    index(gitlab_group.groups[*].name, "application-repos")
  ].id
  key = "SONAR_KEYSTORE_PW"
  value = var.sonar_keystore_pw
  protected = false
  masked = false
  environment_scope = "*"

  depends_on = [
    gitlab_group.groups
  ]
}
