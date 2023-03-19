
GITLAB_URL="https://gitlab.example.com"
ADMIN_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode ; echo)


curl -k -v -L -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "login=root&password=$ADMIN_PASSWORD" \
  "https://gitlab.example.com/api/v4/session?login=root&password=$ADMIN_PASSWORD"

exit

curl -k -c cookies.txt -d "user[login]=root&user[password]=yOkfWeHYVoriqnaUObEeHPEdJCfLSnIudjO9BvsI7z4PiVAPBxMnrOZM0ZvwU0JP" https://gitlab.example.com/users/sign_in

curl -k -v -X POST \
  -H "Content-Type: application/json" \
  -d '{"login": "root", "password": "$(ADMIN_PASSWORD)"}' \
  "https://gitlab.example.com/api/v4/session?login=root&password=$(ADMIN_PASSWORD)"


curl --request POST --header "Content-Type: application/json" --data '{"login": "<username>", "password": "<password>"}' "https://gitlab.example.com/api/v4/session?login=<username>&password=<password>"

exit

echo "login=root&password=$ADMIN_PASSWORD"

curl -k -v -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "login=root&password=$ADMIN_PASSWORD" \
  "$GITLAB_URL/users/sign_in" --cookie-jar cookies.txt

exit 

echo hello
# 
# 
  Authenticate the user and obtain an authentication cookie
# curl --request POST --header "Content-Type: application/x-www-form-urlencoded" --data "login=root&password=your_password" "https://your.gitlab.server.com/users/sign_in"
# 
Create a personal access token using the authentication cookie
# curl --request POST --header "PRIVATE-TOKEN: your_private_token" --data "name=my_token&expires_at=2023-12-31&scopes[]=api" "https://your.gitlab.server.com/api/v4/users/1/personal_access_tokens"