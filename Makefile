VERSION=3.4.14
PROJECT_ID=k8szookeeper
PROJECT=aaroniscode/${PROJECT_ID}

all: build

build:
	docker build --pull -t ${PROJECT}:${VERSION} .

push: build
	docker push ${PROJECT}:${VERSION}

.PHONY: all build push
