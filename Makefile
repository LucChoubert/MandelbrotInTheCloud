IMAGEBACK   := lucchoubert/mandelbrotbackend
IMAGEFRONT   := lucchoubert/mandelbrotfrontend
TAGDEV       := latest
TAG          := $(shell git log -1 --pretty=%h)
DEPLOYMENT   := deployment/covidattestationgenerator
PWD          := $(shell pwd)

all_dev: build_dev run_dev

all_prd: build_prd run_prd

build_dev:
	docker build --target DEV -t $(IMAGEBACK)-dev:$(TAGDEV) -f Containerfile.backend .
	#docker tag $(IMAGEBACK)-dev:$(TAG) $(IMAGEBACK):latest
 
run_dev:
	docker run -it --mount type=bind,source=$(PWD)/backend/,target=/app --mount type=bind,source=$(PWD)/frontend/,target=/app/static/ -p 5000:5000 $(IMAGEBACK)-dev

build_prd:
	docker build --target PRD -t $(IMAGEBACK):$(TAGDEV) -f Containerfile.backend .
	docker build -t $(IMAGEFRONT):$(TAGDEV) -f Containerfile.frontend .

run_prd:
	docker run -d -p 5000:5000 $(IMAGEBACK)
	docker run -d -p 8080:80 $(IMAGEFRONT)

push:
	docker push ${IMAGEBACK}

clean:
	docker IMAGEBACK rm -f ${IMAGEBACK}-dev:latest
	docker IMAGEBACK rm -f ${IMAGEBACK}:latest
	docker IMAGEFRONT rm -f ${IMAGEBACK}-dev:latest
	docker IMAGEFRONT rm -f ${IMAGEBACK}:latest

login:
	docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}