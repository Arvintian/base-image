VERSION     = 1.3.2
PROJECT     = base-image

build:
	docker build -t $(PROJECT):$(VERSION) .

publish:
	docker tag $(PROJECT):$(VERSION) registry.cn-beijing.aliyuncs.com/arvintian/$(PROJECT):$(VERSION)
	docker push registry.cn-beijing.aliyuncs.com/arvintian/$(PROJECT):$(VERSION)
	docker tag $(PROJECT):$(VERSION) arvintian/$(PROJECT):$(VERSION)
	docker push arvintian/$(PROJECT):$(VERSION)