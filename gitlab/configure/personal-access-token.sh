# curl -Lk "https://gitlab.gitlab.local/oauth/token" -d "grant_type=password&username=root&password=temp0ral"
BASE_FQDN=gitlab.local
PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 --decode ; echo)
FULL_OAUTH_TOKEN=$(curl -Lk "https://gitlab.$BASE_FQDN/oauth/token" \
  -d "grant_type=password&username=root&password=$PASSWORD")

OAUTH_TOKEN=$(echo -n $FULL_OAUTH_TOKEN | jq -r .access_token)

IN_TWO_WEEKS=$(date +"%Y-%m-%d" -d "+15days")
FULL_PERSONAL_ACCESS_TOKEN=$(curl -Lk "https://gitlab.$BASE_FQDN/api/v4/users/1/personal_access_tokens?access_token=$OAUTH_TOKEN" \
  -d "expires_at=$IN_TWO_WEEKS" \
  -d "name=mytoken2" \
  -d "scopes[]=api" \
  -d "scopes[]=read_user" \
  -d "scopes[]=read_repository" \
  -d "scopes[]=write_repository" \
  -d "scopes[]=read_registry" \
  -d "scopes[]=write_registry")

PERSONAL_ACCESS_TOKEN=$(echo $FULL_PERSONAL_ACCESS_TOKEN | jq '.token')

echo "Gitlab PAT: $PERSONAL_ACCESS_TOKEN" | tee /dev/tty >> /tmp/cluster.txt

