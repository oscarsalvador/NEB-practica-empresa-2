#!/bin/bash

BASE_FQDN=gitlab.local

# creacion del docker easyrsa para ca

sudo rm -rf ca
mkdir -p ca/certs
cd ca

cat <<EOF > Dockerfile
FROM alpine
RUN apk add --no-cache easy-rsa bash && \
    mkdir /pki && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/bin/easyrsa
COPY docker-entrypoint.sh /
WORKDIR /pki
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--help"]
EOF

cat <<EOF > docker-entrypoint.sh
#!/bin/bash

set -e

if [ ! -f "/pki/openssl-easyrsa.cnf" ]; then
    echo "No OpensslConfig for EasyRsa Found. Copying the default"
    cp /usr/share/easy-rsa/openssl-easyrsa.cnf /pki/openssl-easyrsa.cnf
    cp -R /usr/share/easy-rsa/x509-types /pki/x509-types
fi

exec /usr/bin/easyrsa \$@
EOF
chmod 755 docker-entrypoint.sh
docker build -t cicd/easyrsa:0.0.1 .

echo "

[Certificados]>>> Creada la imagen docker de la CA
"


# creacion de la ca

docker run --rm -v $(pwd)/certs:/pki cicd/easyrsa:0.0.1 init-pki

docker run -i --rm -v $(pwd)/certs:/pki cicd/easyrsa:0.0.1 build-ca <<EOF
gitlab
gitlab
gitlab
gitlab
CA Ltd
EOF

docker run --rm -v $(pwd)/certs:/pki --entrypoint openssl cicd/easyrsa:0.0.1 x509 -text -in /pki/pki/ca.crt -noout

echo "

[Certificados]>>> Creada la CA
"



# creacion de pk/csr del site

openssl genrsa -out $BASE_FQDN.key 2048
openssl req -new -key $BASE_FQDN.key -out $BASE_FQDN.csr <<EOF
ES
Madrid
Madrid
Gitlab Lab

*.$BASE_FQDN
admin@$BASE_FQDN


EOF

openssl req -text -in $BASE_FQDN.csr

echo "

[Certificados]>>> Creada la clave privada del sitio y el CSR
"


# envio del csr a la pki para su firma

cp $BASE_FQDN.csr certs/
hoy=$(date "+%Y%m%d")
docker run --rm -v $(pwd)/certs:/pki cicd/easyrsa:0.0.1 import-req $BASE_FQDN.csr $BASE_FQDN.$hoy
docker run -i --rm -v $(pwd)/certs:/pki cicd/easyrsa:0.0.1 sign-req server $BASE_FQDN.$hoy <<EOF
yes
gitlab
EOF

docker run --rm -v $(pwd)/certs:/pki --entrypoint cp cicd/easyrsa:0.0.1 /pki/pki/issued/$BASE_FQDN.$hoy.crt /pki/$BASE_FQDN.crt
docker run --rm -v $(pwd)/certs:/pki --entrypoint chmod cicd/easyrsa:0.0.1 644 /pki/$BASE_FQDN.crt
cp certs/$BASE_FQDN.crt .

docker run --rm -v $(pwd)/certs:/pki --entrypoint cp cicd/easyrsa:0.0.1 /pki/pki/ca.crt /pki/ca.crt
docker run --rm -v $(pwd)/certs:/pki --entrypoint chmod cicd/easyrsa:0.0.1 644 /pki/ca.crt
cp certs/ca.crt .

echo "

[Certificados]>>> Firmado el CSR, tenemos PK y CRT del sitio y de la CA
"

pwd
ls -lah ./{ca*,$BASE_FQDN*}


echo "

[Certificados]>>> Importando en el cliente la CA
"

sudo cp ca.crt /usr/share/ca-certificates/trust-source/anchors/$BASE_FQDN.ca.crt
sudo update-ca-trust extract
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt | grep "CA Ltd"

echo "

[Certificados]>>> CA Importada, arrancar el navegador de nuevo
"

echo "

[Certificados]>>> Actualizando el secreto en kubernetes
"

# OJO: asumo que el current-context seleeciona el namespace

kubectl get secrets gitlab-tls-cert -o NAME
[ $? = 0 ] && kubectl delete secret gitlab-tls-cert
kubectl create secret tls gitlab-tls-cert --cert=$BASE_FQDN.crt --key=$BASE_FQDN.key
kubectl rollout restart deployment gitlab-nginx-ingress-controller

echo "

[Certificados]>>> Secreto actualizado, ingress rolled out
"


echo "

[Certificados]>>> Verificando la validez de la conexion https
"

openssl s_client -connect gitlab.$BASE_FQDN:443 -prexit


