# base image

一个配置好语言环境及构建相关工具的容器镜像，可以在ci/cd build environment,vscode-remote for container等场景用

## Usage
```
docker pull arvintian/base-image:<version>
```

## 1.0.0
- ubuntu 16.04
- docker 18.09.8
- python3 3.7
- python2 2.7
- go 1.12.9
- node 10.16.3