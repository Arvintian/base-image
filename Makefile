VERSION	= 2.4.0
PROJECT	= base-image
IMAGE	= arvintian/base-image
ARCHITECTURES = amd64 arm64 arm
IMAGE_NAMES += $(foreach arch, $(ARCHITECTURES), $(IMAGE)-$(arch):$(VERSION))

.PHONY: build
build:
	for ARCH in $(ARCHITECTURES) ; do \
		docker buildx build \
			-t $(IMAGE)-$$ARCH:$(VERSION) \
			--platform linux/$$ARCH \
			. ; \
	done ;

.PHONY: push
push:
	for ARCH in $(ARCHITECTURES) ; do \
		docker push $(IMAGE)-$$ARCH:$(VERSION) ; \
	done ;
	docker manifest create --amend $(IMAGE):$(VERSION) $(IMAGE_NAMES)
	docker -D manifest push $(IMAGE):$(VERSION)
	docker manifest create --amend $(IMAGE):latest $(IMAGE_NAMES)
	docker -D manifest push $(IMAGE):latest