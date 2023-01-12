set -e

apt install -y python3 python3-pip python3-apt python3.8 python3.8-dev && mkdir -p /compiler/miniconda3/bin && \
ln -s /usr/bin/python3.8 /compiler/miniconda3/bin/python3 && ln -s /usr/bin/python3.8 /compiler/miniconda3/bin/python && \
cp /usr/bin/pip3 /compiler/miniconda3/bin/pip && sed -i 's+/usr/bin/python3+/usr/bin/env python3+g' /compiler/miniconda3/bin/pip && pip install -U pip
tee /compiler/miniconda3/bin/pip >/dev/null << EOF
#!/compiler/miniconda3/bin/python

# -*- coding: utf-8 -*-
import re
import sys

from pip._internal.cli.main import main

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw?|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
EOF
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && pip install -U setuptools
wget -O /tmp/go.tgz "https://golang.google.cn/dl/go${GOLANG_VERSION}.linux-armv6l.tar.gz" && \
mkdir ${COMPILER_PATH}/go && tar --extract --file /tmp/go.tgz --strip-components 1 --directory ${COMPILER_PATH}/go && \
wget -O /tmp/node.tgz "https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/${NODE_VERSION}/node-${NODE_VERSION}-linux-armv7l.tar.xz" && \
mkdir ${COMPILER_PATH}/node && tar --extract --file /tmp/node.tgz --strip-components 1 --directory ${COMPILER_PATH}/node