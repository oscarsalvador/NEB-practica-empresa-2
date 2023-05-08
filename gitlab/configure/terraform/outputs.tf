output "groups" {
  value = gitlab_group.groups[*].name
  # sensitive = true
}

# output "topics" {
#   value = gitlab_topic.topics[*].name
# }
# distinct(concat(var.projects[*].topics))


output "projects" {
  value = [for i in gitlab_project.projects : {
    name = i.name
    namespace = i.path_with_namespace
    url = i.http_url_to_repo
    id = i.id
  }]
  # sensitive = true
}

# output "memberships" {
#   value = [for i in local.memberships: {
#     membership = join(",", [
#       i.project,
#       i.username,
#       i.access
#     ])
#   }]
# }

output "memberships" {
  value = [for i in gitlab_project_membership.memberships: {
    membership = join(",", [
      gitlab_project.projects[
        index(gitlab_project.projects[*].id, i.project_id)
      ].name,
      # i.project_id,
      # local.users[
      #   index(local.users, i.user_id)
      # ].name,
      # local.users[
      #   index(local.users[*].id, 5)
      # ].name,
      # gitlab_user.users[
      #   index(gitlab_user.users[*].id, i.user_id)
      # ].name,
      i.user_id,
      i.access_level
    ])
  }]
}

output "variables" {
  # value =  local.vars
  value = join(",", gitlab_group_variable.variables[*].key)
}

output "users" {
  value = [for i in values(gitlab_user.users) : {
    id = i.id
    name = i.name
    password = nonsensitive(i.password)
  }]
  # value = gitlab_user.users[
  #   index(toset(gitlab_user.users[*].name), "developer1")
  # ]
  # value = gitlab_user.users[
  #   index({for i in values(gitlab_user.users): "${i}" => i.name}, "developer1")
  # ]
  # value = nonsensitive(values(gitlab_user.users)[0].password)
}


# output "envs" {
#   value = values(gitlab_project_environment.environments
# }

# output "code_projects" {
#   value = [for i in local.code_projects: {
#     project_name = i.project.name
#     branch = i.branch
#   }]
# }

output "code_branch_protections" {
  value = [for i in setunion(
    gitlab_branch_protection.code_branch_protections,
    gitlab_branch_protection.infra_branch_protections
    ): {
    # prot = "${i.project} ${i.branch}"
    project_name = i.project
    branch = i.branch
  }]
}