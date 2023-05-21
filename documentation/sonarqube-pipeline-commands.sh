export SONAR_SCANNER_OPTS="-Djavax.net.ssl.trustStore="/builds/app-repos/backend-code/truststore.jks" -Djavax.net.ssl.trustStorePassword=$SONAR_KEYSTORE_PW"
sonar-scanner -Dsonar.projectKey="$CI_PROJECT" -Dsonar.sources=. -Dsonar.host.url="https://sonar.gitlab.local/" -Dsonar.login="$SONAR_TOKEN" -X

