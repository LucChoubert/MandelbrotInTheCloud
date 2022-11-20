DOCKER       := podman
APPNAME      := MandelbrotApp
IMAGEBACK    := mandelbrotbackend
IMAGEFRONT   := mandelbrotfrontend
TAGDEV       := latest
TAG          := $(shell git log -1 --pretty=%h)
DEPLOYMENT   := deployment/covidattestationgenerator
PWD          := $(shell pwd)

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