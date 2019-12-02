# orgin from https://medium.com/@nieldw/curling-the-kubernetes-api-server-d7675cfc398c

set -x -e

### install jq, base64, curl, e.g., apt-get/yum update && apt-get/yum install -y jq  base64  curl

kubectl create serviceaccount api-explorer

cat <<EOF | kubectl apply -f -
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: log-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list"]
EOF


kubectl create rolebinding api-explorer:log-reader --clusterrole log-reader --serviceaccount default:api-explorer

SERVICE_ACCOUNT=api-explorer

SECRET=$(kubectl get serviceaccount ${SERVICE_ACCOUNT} -o json | jq -Mr '.secrets[].name | select(contains("token"))')

TOKEN=$(kubectl get secret ${SECRET} -o json | jq -Mr '.data.token' | base64 -d)

kubectl get secret ${SECRET} -o json | jq -Mr '.data["ca.crt"]' | base64 -d > /tmp/ca.crt

APISERVER=https://$(kubectl -n default get endpoints kubernetes --no-headers | awk '{ print $2 }')
