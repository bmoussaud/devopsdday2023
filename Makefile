db_clean:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/clear

load_h2: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/h2

load_helm: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/bitnami

load_operator: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/vmware

load_crossplane: db_clean
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/crossplane

playlist:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist | jq

deploy_app:
	kubectl apply	 -f app/playlist-frontend-angular -f app/playlist-service-springboot

deploy_db_helm:
	kubectl apply -f helm/class-claim-bitnami.yaml

bind_db_helm:
	kubectl apply -f helm/serviceclaims.yml

bind_db_operator:
	kubectl apply -f operator/serviceclaims.yml

secret_db_operator:
	kubectl get secret devopsdday2023-database-app-user-db-secret  -o go-template='{{range $$k,$$v := .data}}{{printf "%s: " $$k}}{{if not $$v}}{{$$v}}{{else}}{{$$v | base64decode}}{{end}}{{"\n"}}{{end}}' | sort


deploy_db_crossplane:
	kubectl apply -f crossplane/crossplane-claim.yaml

status_db_crossplane:
	kubectl get postgresqlinstance.azure.database.tanzu.moussaud.org/musicstore-pgsql-crossplane 

status_db_crossplane_d:
	kubectl get xpostgresqlinstances.azure.database.tanzu.moussaud.org -o yaml | yq '.items[].spec'
		
bind_db_crossplane:
	kubectl apply -f crossplane/serviceclaims.yml

secret_db_crossplane:
	kubectl get secret musicstore-pgsql-crossplane-secret  -o go-template='{{range $$k,$$v := .data}}{{printf "%s: " $$k}}{{if not $$v}}{{$$v}}{{else}}{{$$v | base64decode}}{{end}}{{"\n"}}{{end}}' | sort

unbind	:
	kubectl delete servicebinding playlist-service-springboot-database