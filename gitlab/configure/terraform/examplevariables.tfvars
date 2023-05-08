groups = [
  {
    name = "application-repos",
    path = "app-repos",
    description = "Contains projects dedicated to the code of applications, instead of infrastructure",
    avatar = "../imgs/code.png"
  },
  {
    name = "infrastructure-repos",
    path = "infra-repos",
    description = "Contains projects dedicated to infrastructure as code, instead of applications",
    avatar = "../imgs/infra_as_code.png"
  }
]

projects = [
  {
    name = "backend-code",
    description = "Repository to store the code for the JS backend server",
    avatar = "../imgs/apollo.png",
    group_name = "application-repos",
    topics = ["JavaScript"]
    environments = ["pre", "pro"]
    members = [
      {
        name = "developer1"
        access = "developer"
      },
      {
        name = "developer2"
        access = "developer"
      },
      {
        name = "maintainer1"
        access = "maintainer"
      }
    ]
  },
  {
    name = "frontend-code",
    description = "Repository to store the code for the TS frontend server",
    avatar = "../imgs/react.png",
    group_name = "application-repos",
    topics = ["TypeScript"]
    environments = ["pre", "pro"]
    members = [
      {
        name = "developer1"
        access = "developer"
      },
      {
        name = "developer2"
        access = "developer"
      },
      {
        name = "maintainer1"
        access = "maintainer"
      }
    ]
  },
  {
    name = "infra-base",
    description = "Repository to store the infrastructure code for the base elements of the webapp",
    avatar = "../imgs/terraform.png",
    group_name = "infrastructure-repos",
    topics = ["Terraform"]
    environments = ["pre", "pro"]
    members = [
      {
        name = "maintainer1"
        access = "maintainer"
      }
    ]
  },
  {
    name = "infra-backend",
    description = "Repository to store the infrastructure code for the backend server",
    avatar = "../imgs/terraform_back.png",
    group_name = "infrastructure-repos",
    topics = ["Backend"]
    environments = ["pre", "pro"]
    members = [
      {
        name = "maintainer1"
        access = "maintainer"
      }
    ]
  },
  {
    name = "infra-frontend",
    description = "Repository to store the infrastructure code for the backend server",
    avatar = "../imgs/terraform_front.png",
    group_name = "infrastructure-repos",
    topics = ["Frontend"]
    environments = ["pre", "pro"]
    members = [
      {
        name = "maintainer1"
        access = "maintainer"
      }
    ]
  },
]
variables = [
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_location", 
    value = "westeurope",
    protected = false,
    masked = false,
    environment_scope = ["*"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_subscription_id", 
    value = "",
    protected = true,
    masked = true,
    environment_scope = ["*"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_tenant_id", 
    value = "",
    protected = true,
    masked = true,
    environment_scope = ["*"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_resource_group_name", 
    value = "rg-gb-prueba-poc-2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_virtual_network_name", 
    value = "vn-gb-prueba-poc-2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_acr_name", 
    value = "acresspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_frontend_container_group_name", 
    value = "acifesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_frontend_container_name", 
    value = "acicfesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_frontend_image", 
    value = "acresspruebapoc2.azurecr.io/fullstackpoc-front:latest",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_backend_container_group_name", 
    value = "acibesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_backend_container_name", 
    value = "acibesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_backend_image", 
    value = "acresspruebapoc2.azurecr.io/fullstackpoc-back:latest",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos", "application-repos"],
    key = "TF_VAR_container_registry_name", 
    value = "acresspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_cosmos_db_account_name", 
    value = "cdaesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_mongo_db_name", 
    value = "mdbesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_redis_db_name", 
    value = "rdbesspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_storage_account_name", 
    value = "esspruebapoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
  {
    groups = ["infrastructure-repos"],
    key = "TF_VAR_storage_container_name", 
    value = "sacesspruebpoc2",
    protected = false,
    masked = false,
    environment_scope = ["pro","pre"]
  },
]