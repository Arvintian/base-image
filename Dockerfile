FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ADD apt/sources.list /etc/apt/sources.list
RUN chmod 644 /etc/apt/sources.list && apt-get update && mkdir /compiler

# base build
ENV TZ=Asia/Shanghai
RUN apt-get install -y apt-utils vim wget curl iputils-ping build-essential sudo openssl openssh-server dumb-init rsyslog cron net-tools && \
    apt-get install -y locales && locale-gen en_US.UTF-8 && \
    apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

# compilers
ENV COMPILER_PATH=/compiler MINICONDA3_VERSION=py37_4.10.3 MINICONDA2_VERSION=py27_4.8.3 GOLANG_VERSION=1.16.7 NODE_VERSION=v10.16.3

RUN wget -O /tmp/miniconda3.sh "https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA3_VERSION}-Linux-x86_64.sh" && \
    chmod a+x /tmp/miniconda3.sh && /tmp/miniconda3.sh -p ${COMPILER_PATH}/miniconda3 -b && \
    wget -O /tmp/miniconda2.sh "https://repo.anaconda.com/miniconda/Miniconda2-${MINICONDA2_VERSION}-Linux-x86_64.sh" && \
    chmod a+x /tmp/miniconda2.sh && /tmp/miniconda2.sh -p ${COMPILER_PATH}/miniconda2 -b && \
    wget -O /tmp/go.tgz "https://golang.google.cn/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" && \
    mkdir ${COMPILER_PATH}/go && tar --extract --file /tmp/go.tgz --strip-components 1 --directory ${COMPILER_PATH}/go && \
    wget -O /tmp/node.tgz "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz" && \
    mkdir ${COMPILER_PATH}/node && tar --extract --file /tmp/node.tgz --strip-components 1 --directory ${COMPILER_PATH}/node && \
    rm -rf /tmp/*

# php
RUN apt-get install -y nginx php7.2-fpm php7.2-common php7.2-json php7.2-gd php7.2-cli php7.2-mbstring php7.2-xml \
    php7.2-opcache php7.2-mysql php7.2-curl php-redis php7.2-bcmath php7.2-zip
ADD nginx/default /etc/nginx/sites-available/default
RUN chmod 644 /etc/nginx/sites-available/default

# nginx & rsyslog logrotate
# fix cron
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=726661
# https://stackoverflow.com/questions/43323754/cannot-make-remove-an-entry-for-the-specified-session-cron
RUN sed -i 's+invoke-rc.d nginx rotate >/dev/null 2>&1+/etc/init.d/nginx rotate+' /etc/logrotate.d/nginx && \
    sed -i 's+/usr/lib/rsyslog/rsyslog-rotate+/etc/init.d/rsyslog rotate+' /etc/logrotate.d/rsyslog && \
    sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron && \
    sed -i '/session    required   pam_limits.so/c\#session    required   pam_limits.so' /etc/pam.d/cron

# setup
ENV PATH=${COMPILER_PATH}/miniconda3/bin:${COMPILER_PATH}/miniconda2/bin:${COMPILER_PATH}/go/bin:${COMPILER_PATH}/node/bin:${PATH}

# add user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -G sudo -p "$(openssl passwd -1 ubuntu)" ubuntu && echo "export PATH=$PATH" >> /home/ubuntu/.bashrc

COPY entrypoint.py /entrypoint/

CMD ["dumb-init","python","-u","/entrypoint/entrypoint.py"]