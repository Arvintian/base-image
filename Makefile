VERSION     = 1.0.0
PROJECT     = base-image

build:
	docker build -t $(PROJECT):$(VERSION) .