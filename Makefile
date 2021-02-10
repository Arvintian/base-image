VERSION     = 1.1.0
PROJECT     = base-image

build:
	docker build -t $(PROJECT):$(VERSION) .