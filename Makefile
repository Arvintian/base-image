VERSION     = 1.2.0
PROJECT     = base-image

build:
	docker build -t $(PROJECT):$(VERSION) .

publish:
	docker tag $(PROJECT):$(VERSION) registry.cn-shanghai.aliyuncs.com/arvintian/$(PROJECT):$(VERSION)