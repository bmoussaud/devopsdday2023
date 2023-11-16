db_clean:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/clear
	
load_h2:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/h2

load_bitnami:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist/load/bitnami

playlist:
	curl https://playlist-service-springboot.devopsdday2023.16x.tanzu.moussaud.org/api/playlist | jq

deploy_app:
	kubectl apply	 -f app/playlist-frontend-angular -f app/playlist-service-springboot

deploy_db_helm:
	kubectl apply -f helm/class-claim-bitnami.yaml

bind_db_helm:
	kubectl apply -f helm/serviceclaims.yml