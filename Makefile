db_clean:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/clear

load_h2: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/artic

load_helm: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/bitnami

load_operator: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/broadcom

load_crossplane: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/crossplane

playlist:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist | jq

deploy_app:
	kubectl apply -f app/playlist-frontend-angular -f app/playlist-service-springboot

deploy_db_helm2:
	kubectl apply -f helm/class-claim-bitnami.yaml

deploy_db_helm:
	helm/create-db-helm-bitnami.sh

undeploy_db_helm:
	helm/delete-db-helm-bitnami.sh

bind_db_helm:
	kubectl apply -f helm/serviceclaims.yml
	bat helm/serviceclaims.yml

deploy_db_operator:
	kubectl apply -f operator/database.yaml -f operator/rc.yaml 
	bat operator/database.yaml
	kubectl get postgres.sql.tanzu.vmware.com -w

deploy_db_operator_ha:
	kubectl apply -f operator/database_ha.yaml -f operator/rc.yaml 
	bat operator/database_ha.yaml
	kubectl get postgres.sql.tanzu.vmware.com -w

undeploy_db_operator:
	kubectl delete -f operator/database.yaml -f operator/rc.yaml 

status_db_operator:
	kubectl get postgres.sql.tanzu.vmware.com musicstore-pgsql-operator -o yaml | yq

bind_db_operator: status_db_operator
	kubectl apply -f operator/serviceclaims.yml
	bat operator/serviceclaims.yml

secret_db_operator:
	kubectl get secret musicstore-pgsql-operator-app-user-db-secret  -o go-template='{{range $$k,$$v := .data}}{{printf "%s: " $$k}}{{if not $$v}}{{$$v}}{{else}}{{$$v | base64decode}}{{end}}{{"\n"}}{{end}}' | sort

deploy_db_crossplane:
	kubectl apply -f crossplane/crossplane-claim.yaml

status_db_crossplane:
	bat crossplane/crossplane-claim.yaml
	kubectl get postgresqlinstance.azure.database.tanzu.moussaud.org/musicstore-pgsql-crossplane 

status_db_crossplane_d: status_db_crossplane
	kubectl get xpostgresqlinstances.azure.database.tanzu.moussaud.org -o yaml | yq '.items[].spec'
		
bind_db_crossplane:
	kubectl apply -f crossplane/serviceclaims.yml
	bat crossplane/serviceclaims.yml

secret_db_crossplane:
	kubectl get secret musicstore-pgsql-crossplane-secret  -o go-template='{{range $$k,$$v := .data}}{{printf "%s: " $$k}}{{if not $$v}}{{$$v}}{{else}}{{$$v | base64decode}}{{end}}{{"\n"}}{{end}}' | sort

unbind:
	kubectl delete servicebinding playlist-service-springboot-database

reset_demo: unbind  undeploy_db_helm undeploy_db_operator
