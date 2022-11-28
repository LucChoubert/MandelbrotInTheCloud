DOCKER       := podman
APPNAME      := MandelbrotApp
IMAGEBACK    := mandelbrotbackend
IMAGEFRONT   := mandelbrotfrontend
TAGDEV       := latest
TAG          := $(shell git log -1 --pretty=%h)
DEPLOYMENT   := deployment/covidattestationgenerator
PWD          := $(shell pwd)


######################################
# Virtual env & VM
######################################

#TODO
.PHONY: run_virtualenv_dev
run_virtualenv_dev:

#TODO
.PHONY: clean_virtualenv_dev
clean_virtualenv_dev:


.PHONY: build_artifact
build_artifact:
	@echo "*************************************"
	@echo "* Build tarball artifact            *"
	@echo "*************************************"
	rm -f virtualmachine/project.tar.gz
	tar -czf virtualmachine/project.tar.gz ./src/backend ./src/frontend
	./virtualmachine/addpayload.sh --base64 virtualmachine/project.tar.gz
	rm -f virtualmachine/project.tar.gz
	write-mime-multipart --output ./virtualmachine/combined-userdata.mime ./virtualmachine/cloud-init-centos.yaml:text/cloud-config ./virtualmachine/install.sh:text/x-shellscript

.PHONY: run_vm_prd
run_vm_prd:
	@echo "*************************************"
	@echo "* Starting VM on azure              *"
	@echo "*************************************"
	az vm list
	az vm create --resource-group myResourceGroup \
				 --name vmApp \
				 --priority Spot \
				 --image OpenLogic:CentOS:8_5:latest \
				 --custom-data ./virtualmachine/combined-userdata.mime \
				 --ssh-key-values ~/.ssh/cloud/ssh-key-2022-09-12.key.pub \
				 --public-ip-sku standard \
				 --nic-delete-option delete \
				 --os-disk-delete-option delete \
				 --public-ip-address-dns-name mandelbrotinthecloud
	az network nsg rule create --resource-group myResourceGroup \
							   --nsg-name vmAppNSG \
							   --name AllowHttpInbound \
							   --priority 1050 \
							   --destination-port-ranges 80 \
							   --access Allow \
							   --protocol Tcp \
							   --description "Allow standard http traffic on port 80 to any IP address"
	az vm list

.PHONY: getip
getip:
	$(eval VMIP  := $(shell az vm show -d -g myResourceGroup -n vmApp --query publicIps -o tsv ))
	$(eval VMDNS := $(shell az vm show -d -g myResourceGroup -n vmApp --query fqdns -o tsv ))
	$(eval VMCONNECT := $(shell [ -z "$(VMDNS)" ] && echo $(VMIP) || echo $(VMDNS) ))
	@echo "******************************************************************************************"
	@echo "* You can test via url: curl http://$(VMCONNECT)/test                                   *"
	@echo "* You can ssh connect with: ssh  -i ~/.ssh/cloud/ssh-key-2022-09-12.key app@$(VMCONNECT) *"
	@echo "* You can connect to MandelbrotInTheCloud via: http://$(VMCONNECT) *"
	@echo "******************************************************************************************"

.PHONY: delete_vm_prd
delete_vm_prd:
	@echo "*************************************************"
	@echo "* Deleting VM & associated ressources on azure  *"
	@echo "*************************************************"
	az vm list
	az vm delete --resource-group myResourceGroup \
				 --name vmApp \
				 --yes
	az network nsg delete --resource-group myResourceGroup \
						  --name vmAppNSG
	az network public-ip delete --resource-group myResourceGroup \
				 				--name vmAppPublicIP
	az network vnet delete --resource-group myResourceGroup \
				 		   --name vmAppVNET
	az vm list


######################################
# Containers
######################################

.PHONY: all_dev
all_dev: build_dev run_dev

.PHONY: all_prd
all_prd: build_prd run_prd

.PHONY: build_dev
build_dev:
	$(DOCKER) build --target DEV -t $(IMAGEBACK)-dev:$(TAGDEV) -f containers/Containerfile.backend .
 
.PHONY: run_dev
run_dev:
	@echo "***************************************************************************"
	@echo "* You can test the code via: http://localhost:5000/static/mandelbrot.html *"
	@echo "* Just update the sources and code will automatically reload              *"
	@echo "***************************************************************************"
	$(DOCKER) run -it --rm --mount type=bind,source=$(PWD)/src/backend/,target=/app --mount type=bind,source=$(PWD)/src/frontend/,target=/app/static/ -p 5000:5000 $(IMAGEBACK)-dev


.PHONY: build_prd
build_prd:
	$(DOCKER) build --target PRD -t $(IMAGEBACK):$(TAGDEV) -f containers/Containerfile.backend .
	$(DOCKER) build -t $(IMAGEFRONT):$(TAGDEV) -f containers/Containerfile.frontend .

.PHONY: run_prd
run_prd:
	@echo "************************************************************"
	@echo "* Starting the application as a pod                        *"
	@echo "*   - podman pod ls: to list the pod                       *"
	@echo "*   - podman ps: to list containers                        *"
	@echo "*   - podman logs $(IMAGEFRONT): to get frontend logs *"
	@echo "*   - podman logs $(IMAGEBACK): to get backend logs   *"
	@echo "************************************************************"
	#$(DOCKER) pod create -p 8080:80 --name $(APPNAME)
	#$(DOCKER) run --pod $(APPNAME) -d $(IMAGEBACK)
	#$(DOCKER) run --pod $(APPNAME) -d $(IMAGEFRONT)
	$(DOCKER) pod stop $(APPNAME)
	$(DOCKER) pod rm $(APPNAME)
	$(DOCKER) play kube containers/MandelbrotAppPod.yaml
	@echo "************************************************************************"
	@echo "* You can access the webapp via: http://localhost:8080/mandelbrot.html *"
	@echo "************************************************************************"

.PHONY: clean_prd
stop_prd:
	$(DOCKER) pod stop $(APPNAME)
	$(DOCKER) pod rm $(APPNAME)

.PHONY: clean_images
clean_images:
	$(DOCKER) image rm -f ${IMAGEBACK}-dev:latest
	$(DOCKER) image rm -f ${IMAGEBACK}:latest
	$(DOCKER) image rm -f ${IMAGEBACK}-dev:latest
	$(DOCKER) image rm -f ${IMAGEBACK}:latest

.PHONY: clean_containers
clean_containers:
	$(DOCKER) rm `$(DOCKER) ps -a | grep "Exited " | cut -f 1`

# Used later for synchro with remote artifacts repo

#.PHONY: push
#push:
#	$(DOCKER) push ${IMAGEBACK}

#login:
#	$(DOCKER) log -u ${DOCKER_USER} -p ${DOCKER_PASS}


