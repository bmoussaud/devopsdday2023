#!/bin/bash
NAMESPACE=devopsdday2023 
helm uninstall musicstore-pgsql-helm  -n ${NAMESPACE}
tanzu services resource-claims delete db-binding-compatible --namespace ${NAMESPACE} -y


