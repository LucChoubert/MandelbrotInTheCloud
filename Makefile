IMAGE        := lucchoubert/mandelbrotbackend
TAGDEV       := latest
TAG          := $(shell git log -1 --pretty=%h)
DEPLOYMENT   := deployment/covidattestationgenerator
PWD          := $(shell pwd)

all_dev: build_dev run_dev

all_prd: build_prd run_prd

build_dev:
	docker build --target DEV -t $(IMAGE)-dev:$(TAGDEV) -f Containerfile .
	#docker tag $(IMAGE)-dev:$(TAG) $(IMAGE):latest
 
run_dev:
	docker run -it --mount type=bind,source=$(PWD)/backend/,target=/app --mount type=bind,source=$(PWD)/frontend/,target=/app/static/ -p 5000:5000 $(IMAGE)-dev

build_prd:
	docker build --target PRD -t $(IMAGE):$(TAGDEV) -f Containerfile .
	#docker tag $(IMAGE):$(TAG) $(IMAGE):latest

run_prd:
	docker run -d -p 5000:5000 $(IMAGE)

push:
	docker push ${IMAGE}

clean:
	docker image rm -f ${IMAGE}-dev:latest
	docker image rm -f ${IMAGE}:latest

login:
	docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}