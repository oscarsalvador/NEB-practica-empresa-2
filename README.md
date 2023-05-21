![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689.svg?style=for-the-badge&logo=Helm&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![cURL](https://img.shields.io/badge/curl-073551.svg?style=for-the-badge&logo=curl&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![gitlab](https://img.shields.io/badge/GitLab-FC6D26.svg?style=for-the-badge&logo=GitLab&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![sonarqube](https://img.shields.io/badge/SonarQube-4E9BCD.svg?style=for-the-badge&logo=SonarQube&logoColor=white)
![owasp](https://img.shields.io/badge/OWASP-000000.svg?style=for-the-badge&logo=OWASP&logoColor=white)
![LaTeX](https://img.shields.io/badge/latex-%23008080.svg?style=for-the-badge&logo=latex&logoColor=white)

# Introduction
DevSecOps k8s cluster with GitLab (configured using Terraform) and pipelines for code with SCA (OWASP dependency check), SAST (Sonarqube) and DAST (Arachni), and infrastructure as code with IaC security analysis (Checkov) to deploy to Azure. Production and preproduction environments.

This repo contains a set of bash scripts to setup a DevSecOps kubernetes cluster in minikube. GitLab and Sonarqube get installed in it, and then GitLab is configured using it's Terraform provider. It requires a host with at least 32 gigabytes of RAM, and eight to twelve cores. The machine needs to have Docker, Helm, Minikube, and Kubectl installed. The three latter can be downloaded and made available to the system with the included `download.sh` script. Another machine is also requried, and it needs to have access to the one in which `launch.sh` is triggered. In my tests I used a VirtualBox virtual machine, but the same host could also be used. This machine needs to have Azure CLI, Docker, and Terraform installed. Additionally, the scripts expect `az-cli` to be already logged into.

Executing `launch.sh` will make changes to the machine's `/etc/hosts`, appending a line with the subdomains that will be used. It will also result in several docker images being downloaded to the local registry.

<br>

<p align="center">
  <img src="./documentation/drawio/cluster2.drawio.png"><br>
  <em>System overview and pipeline job placement</em>
</p>

# Pipelines
Code pipelines
- Source Code Analysis (SCA) with OWASP dependency check
- Static Aplication Security Testing (SAST) with Sonarqube
- Building and pushing of Docker images to Azure Container Registry
- Manual deployment of the images to Azure Container Instances to production or preproduction depending on the branch
- Dynamic Aplication Security Testing (DAST) with Arachni

<br>

Infrastructure pipelines
- Infrastructure as Code security analysis with Checkov
- Automatic planning of the Terraform project
- Manual deployment of the IaC to production or preproduction depending on the branch