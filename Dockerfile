FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ADD apt/sources.list /etc/apt/sources.list
RUN chmod 644 /etc/apt/sources.list
RUN apt-get update

# base build
RUN apt-get install -y apt-utils
RUN apt-get install -y vim wget curl iputils-ping build-essential sudo openssl openssh-server dumb-init
RUN apt-get install -y rsyslog cron
RUN apt-get install -y locales && locale-gen en_US.UTF-8

# set timezone
ENV TZ=Asia/Shanghai
RUN apt install -y tzdata && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

# fix cron
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=726661
# https://stackoverflow.com/questions/43323754/cannot-make-remove-an-entry-for-the-specified-session-cron
RUN sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron
RUN sed -i '/session    required   pam_limits.so/c\#session    required   pam_limits.so' /etc/pam.d/cron

# prepare
RUN mkdir /compiler
ENV COMPILER_PATH /compiler

# miniconda3
RUN wget -O /tmp/miniconda3.sh "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
    chmod a+x /tmp/miniconda3.sh && /tmp/miniconda3.sh -p ${COMPILER_PATH}/miniconda3 -b

# miniconda2
# Something depend on python2
RUN wget -O /tmp/miniconda2.sh "https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh" && \
    chmod a+x /tmp/miniconda2.sh && /tmp/miniconda2.sh -p ${COMPILER_PATH}/miniconda2 -b

# golang
ENV GOLANG_VERSION 1.14.15
RUN wget -O /tmp/go.tgz "https://studygolang.com/dl/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz" && \
    mkdir ${COMPILER_PATH}/go && tar --extract --file /tmp/go.tgz --strip-components 1 --directory ${COMPILER_PATH}/go

# node
ENV NODE_VERSION v10.16.3
RUN wget -O /tmp/node.tgz "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz" && \
    mkdir ${COMPILER_PATH}/node && tar --extract --file /tmp/node.tgz --strip-components 1 --directory ${COMPILER_PATH}/node

# php
RUN apt-get install -y nginx
RUN apt-get install -y php7.2-fpm php7.2-common php7.2-json php7.2-gd php7.2-cli php7.2-mbstring php7.2-xml \
    php7.2-opcache php7.2-mysql php7.2-curl php-redis php7.2-bcmath php7.2-zip
ADD nginx/default /etc/nginx/sites-available/default
RUN chmod 644 /etc/nginx/sites-available/default

# nginx && fpm log
# RUN ln -sfT /dev/stderr "/var/log/nginx/error.log" && ln -sfT /dev/stdout "/var/log/nginx/access.log"
# RUN ln -sfT /dev/stderr "/var/log/php7.2-fpm.log"

# docker client
# ENV DOCKER_VERSION 18.09.8
# # If you're using kubernetes you should run a docker:dind container in the same pod.
# ENV DOCKER_HOST='tcp://localhost:2375'
# RUN wget -O /tmp/docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" && \
#     tar --extract --file /tmp/docker.tgz --strip-components 1 --directory /usr/local/bin/

# nginx & rsyslog logrotate
RUN sed -i 's+invoke-rc.d nginx rotate >/dev/null 2>&1+/etc/init.d/nginx rotate+' /etc/logrotate.d/nginx
RUN sed -i 's+/usr/lib/rsyslog/rsyslog-rotate+/etc/init.d/rsyslog rotate+' /etc/logrotate.d/rsyslog

# setup
ENV PATH=${COMPILER_PATH}/miniconda3/bin:${COMPILER_PATH}/miniconda2/bin:${COMPILER_PATH}/go/bin:${COMPILER_PATH}/node/bin:${PATH}

# add user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -G sudo -p "$(openssl passwd -1 ubuntu)" ubuntu
RUN echo "export PATH=$PATH" >> /home/ubuntu/.bashrc

# clean
RUN rm -rf /tmp/*

COPY entrypoint.py /entrypoint/
COPY init.json /entrypoint/

ENTRYPOINT ["dumb-init","python","-u","/entrypoint/entrypoint.py"]