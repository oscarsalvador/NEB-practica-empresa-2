#!/bin/bash
BASE_FQDN="gitlab.local"

echo "[setup-runner-setup]>>> Creating runner-setup.sh script"
CA_CRT=$(cat ../ca/ca.crt)

echo "
#!/bin/bash

echo \"[runner-setup]>>> Copying ca.crt to /usr/share/ca-certificates/trust-source/anchors/$BASE_FQDN.ca.crt\"
echo \"$CA_CRT\" > ca.crt
sudo cp ca.crt /usr/share/ca-certificates/trust-source/anchors/$BASE_FQDN.ca.crt
sudo update-ca-trust extract

DOMAINS=\"$(minikube ip --profile cicd) gitlab.gitlab.local minio.gitlab.local kas.gitlab.local registry.gitlab.local sonar.gitlab.local\"
if ! grep -q \"$DOMAINS\" /etc/hosts; then
  echo $DOMAINS | sudo tee -a /etc/hosts
fi

status=\$(curl -s -o /dev/null -w \"%{http_code}\" https://gitlab.$BASE_FQDN/users/sign_in)
if [[ \$status -ne 200 ]]; then 
  echo \"Cannot access gitlab instance\"
  exit
fi

if [ ! -f gitlab-runner ]; then 
  echo \"Runner not available in directory, downloading\"
  curl -L --output gitlab-runner \"https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64\"
fi
chmod +x gitlab-runner

rm /home/user/.gitlab-runner/config.toml 
rm -rf ./builds
./gitlab-runner unregister --all-runners
./gitlab-runner list

./gitlab-runner register --url https://gitlab.$BASE_FQDN \\
  --registration-token $(kubectl get secret gitlab-gitlab-runner-secret -n gitlab -o jsonpath='{.data.runner-registration-token}' | base64 --decode ; echo) \\
  --description VirtualBox \\
  --tag-list \"Azure,Docker\" \\
  --maintenance-note \"Runner with az-cli and docker\" \\
  --non-interactive \\
  --executor shell

curl -v --header \"PRIVATE-TOKEN: $1\" \"https://gitlab.gitlab.local/api/v4/runners/all\"

./gitlab-runner run

" > runner-setup.sh

chmod +x runner-setup.sh
echo "

[setup-runner-setup]>>> Press any key once the $(pwd)/runner-setup.sh script has been copied and run in the desired machine, and it is registered and running as a runner
"
read