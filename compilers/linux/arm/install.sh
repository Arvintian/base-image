apt install -y python3 python3-pip python3-apt && mkdir -p /compiler/miniconda3/bin && \
ln -s /usr/bin/python3 /compiler/miniconda3/bin/python && ln -s /usr/bin/pip3 /compiler/miniconda3/bin/pip && \
wget -O /tmp/go.tgz "https://golang.google.cn/dl/go${GOLANG_VERSION}.linux-armv6l.tar.gz" && \
mkdir ${COMPILER_PATH}/go && tar --extract --file /tmp/go.tgz --strip-components 1 --directory ${COMPILER_PATH}/go && \
wget -O /tmp/node.tgz "https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/${NODE_VERSION}/node-${NODE_VERSION}-linux-armv7l.tar.xz" && \
mkdir ${COMPILER_PATH}/node && tar --extract --file /tmp/node.tgz --strip-components 1 --directory ${COMPILER_PATH}/node