VERSION	= 2.1.0
PROJECT	= base-image
IMAGE	= arvintian/base-image
ARCHITECTURES = amd64 arm64 arm

.PHONY: build
build:
	for ARCH in $(ARCHITECTURES) ; do \
		docker buildx build \
			-t $(IMAGE)-$$ARCH:$(VERSION) \
			--platform linux/$$ARCH \
			. ; \
	done ; \

.PHONY: manifest-bundle
manifest-bundle: build
	docker tag $(PROJECT):$(VERSION) arvintian/$(PROJECT):$(VERSION)

.PHONY: push
push: manifest-bundle
	docker push arvintian/$(PROJECT):$(VERSION)