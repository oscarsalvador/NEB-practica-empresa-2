output "groups" {
  value = gitlab_group.groups[*].name
  # sensitive = true
}

# output "topics" {
#   value = gitlab_topic.topics[*].name
# }


output "projects" {
  value = [for i in gitlab_project.projects : {
    name = i.name
    namespace = i.path_with_namespace
    url = i.http_url_to_repo
  }]
  # sensitive = true
}


output "variables" {
  value = join(",", gitlab_group_variable.variables[*].key)
}
# output "test" {
#   value = distinct(flatten(var.projects[*].topics))
# }

# distinct(concat(var.projects[*].topics))
