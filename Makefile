DOCKER       := podman
APPNAME      := MandelbrotApp
IMAGEBACK    := lucchoubert/mandelbrotbackend
IMAGEFRONT   := lucchoubert/mandelbrotfrontend
TAGDEV       := latest
TAG          := $(shell git log -1 --pretty=%h)
DEPLOYMENT   := deployment/covidattestationgenerator
PWD          := $(shell pwd)

all_dev: build_dev run_dev

all_prd: build_prd run_prd

build_dev:
	$(DOCKER) build --target DEV -t $(IMAGEBACK)-dev:$(TAGDEV) -f Containerfile.backend .
	#$(DOCKER) tag $(IMAGEBACK)-dev:$(TAG) $(IMAGEBACK):latest
 
run_dev:
	$(DOCKER) run -it --mount type=bind,source=$(PWD)/backend/,target=/app --mount type=bind,source=$(PWD)/frontend/,target=/app/static/ -p 5000:5000 $(IMAGEBACK)-dev

build_prd:
	$(DOCKER) build --target PRD -t $(IMAGEBACK):$(TAGDEV) -f Containerfile.backend .
	$(DOCKER) build -t $(IMAGEFRONT):$(TAGDEV) -f Containerfile.frontend .

run_prd:
	#$(DOCKER) pod create -p 8080:80 --name $(APPNAME)
	#$(DOCKER) run --pod $(APPNAME) -d $(IMAGEBACK)
	#$(DOCKER) run --pod $(APPNAME) -d $(IMAGEFRONT)
	$(DOCKER) play kube MandelbrotAppPod.yaml

stop_prd:
	$(DOCKER) pod stop $(APPNAME)
	$(DOCKER) pod rm $(APPNAME)

push:
	$(DOCKER) push ${IMAGEBACK}

clean:
	$(DOCKER) image rm -f ${IMAGEBACK}-dev:latest
	$(DOCKER) image rm -f ${IMAGEBACK}:latest
	$(DOCKER) image rm -f ${IMAGEBACK}-dev:latest
	$(DOCKER) image rm -f ${IMAGEBACK}:latest

login:
	$(DOCKER) log -u ${DOCKER_USER} -p ${DOCKER_PASS}