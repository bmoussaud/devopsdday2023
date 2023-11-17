#!/bin/bash
set -x
NAMESPACE=devopsdday2023
helm uninstall musicstore-pgsql-helm -n ${NAMESPACE}
tanzu services resource-claims delete musicstore-pgsql-bitnami --namespace ${NAMESPACE} -y
