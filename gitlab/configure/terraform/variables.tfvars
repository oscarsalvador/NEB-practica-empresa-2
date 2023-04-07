groups = [
  {
    name = "application-repos",
    path = "app-repos",
    description = "Contains projects dedicated to the code of applications, instead of infrastructure",
    avatar = "../pics/code.png"
  },
  {
    name = "infrastructure-repos",
    path = "infra-repos",
    description = "Contains projects dedicated to infrastructure as code, instead of applications",
    avatar = "../pics/infra_as_code.png"
  }
]

projects = [
  {
    name = "backend-code",
    description = "Repository to store the code for the JS backend server",
    avatar = "../pics/apollo.png",
    group_name = "application-repos",
    topics = ["JavaScript"]
  },
  {
    name = "frontend-code",
    description = "Repository to store the code for the TS frontend server",
    avatar = "../pics/react.png",
    group_name = "application-repos",
    topics = ["TypeScript"]
  },
  {
    name = "infra-base",
    description = "Repository to store the infrastructure code for the base elements of the webapp",
    avatar = "../pics/terraform.png",
    group_name = "infrastructure-repos",
    topics = ["Terraform"]
  },
  {
    name = "infra-backend",
    description = "Repository to store the infrastructure code for the backend server",
    avatar = "../pics/terraform_back.png",
    group_name = "infrastructure-repos",
    topics = ["Backend"]
  },
  {
    name = "infra-frontend",
    description = "Repository to store the infrastructure code for the backend server",
    avatar = "../pics/terraform_front.png",
    group_name = "infrastructure-repos",
    topics = ["Frontend"]
  },
]