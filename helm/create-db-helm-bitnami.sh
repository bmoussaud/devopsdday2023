#!/bin/bash

function kdecsec() {
    secname=$1
    echo "Secret: $*"
    kubectl get secret $*  -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
}


NAMESPACE=devopsdday2023 
echo ""
echo ">>Deploy a new PGSQL Database using Helm & Bitnami...."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo postgresql
helm install musicstore-pgsql-helm bitnami/postgresql --set global.postgresql.auth.postgresPassword=password --set global.postgresql.auth.database=musicstore-pgsql-helm --set serviceBindings.enabled=true -n ${NAMESPACE}
echo "/Deploy a new PGSQL Database using Helm & Bitnami"

echo ""

echo ">>Wait for the end of the deployment......"
kubectl get statefulsets.apps -n ${NAMESPACE}  musicstore-pgsql-helm-postgresql
set -x 
kubectl wait -l statefulset.kubernetes.io/pod-name=musicstore-pgsql-helm-postgresql-0  --for=condition=ready pod --timeout=-1s -n ${NAMESPACE}
kubectl get pods -n ${NAMESPACE} musicstore-pgsql-helm-postgresql-0
set +x 
echo "end of the deployment..."

echo ""
echo ">>Dump the generated secret...."
set -x 
kubectl get secret musicstore-pgsql-helm-postgresql-svcbind-postgres -n ${NAMESPACE}
set +x
kdecsec musicstore-pgsql-helm-postgresql-svcbind-postgres -n ${NAMESPACE}

echo ""
echo ">>Create the claim"
tanzu service resource-claims create musicstore-pgsql-with-helm --resource-name musicstore-pgsql-helm-postgresql-svcbind-postgres --resource-kind Secret --resource-api-version v1 -n ${NAMESPACE}
tanzu services resource-claims get musicstore-pgsql-with-helm --namespace ${NAMESPACE}

echo "Done"