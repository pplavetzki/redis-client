ENV    ?= dev
ACR    := pplavetzki
AUTO_NAME = ${ACR}.azurecr.io/${ENV}
TAG    := $(shell date +"%Y%m%d.${GITHUB_RUN_NUMBER}")
TEN    := $(TENANT)
SP_PSW := $(SP_PASSWORD)

SECRETS ?= .secrets.sh

.PHONY: az-login
az-login:
	@echo "Logging into Azure"
	@az login --service-principal -u $(APPLICATION_ID) -p ${SP_PSW} --tenant ${TEN} > /dev/null

.PHONY: docker-login
docker-login: az-login
	@az acr login --name $(ACR).azurecr.io -u $(APPLICATION_ID) -p ${SP_PSW}

.PHONY: build-image
build-image:
	docker build -t ${AUTO_NAME}/redis-client:${TAG} -f Dockerfile .
	docker tag ${AUTO_NAME}/redis-client:${TAG} ${AUTO_NAME}/redis-client:latest

.PHONY: publish
publish: docker-login
	docker push ${AUTO_NAME}/redis-client:${TAG}
	docker push ${AUTO_NAME}/redis-client:latest