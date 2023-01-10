wget -O /tmp/miniconda3.sh "https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-${MINICONDA3_VERSION}-Linux-aarch64.sh" && \
chmod a+x /tmp/miniconda3.sh && /tmp/miniconda3.sh -p ${COMPILER_PATH}/miniconda3 -b && \
wget -O /tmp/go.tgz "https://golang.google.cn/dl/go${GOLANG_VERSION}.linux-arm64.tar.gz" && \
mkdir ${COMPILER_PATH}/go && tar --extract --file /tmp/go.tgz --strip-components 1 --directory ${COMPILER_PATH}/go && \
wget -O /tmp/node.tgz "https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/${NODE_VERSION}/node-${NODE_VERSION}-linux-arm64.tar.xz" && \
mkdir ${COMPILER_PATH}/node && tar --extract --file /tmp/node.tgz --strip-components 1 --directory ${COMPILER_PATH}/node