INGRESS_NODE_IP=$(kubectl get -n ingress-nginx pod $(kubectl get pods -A | grep ingress-nginx-controller | awk '{print $2}') -o jsonpath='{.status.hostIP}')
kubectl get configmap coredns -n kube-system -o json > coredns.json

OLDJSON="$(jq -r '.data.Corefile' coredns.json)"
COREFILE_VALUE="$OLDJSON
  gitlab.local:53 { 
    errors 
    cache 30 
    hosts { 
      $INGRESS_NODE_IP gitlab.gitlab.local minio.gitlab.local registry.gitlab.local sonar.gitlab.local
    }
  }
"
jq --arg COREDNS "$COREFILE_VALUE" '.data.Corefile |= $COREDNS' coredns.json> coredns-fix.json
kubectl apply -f coredns-fix.json

