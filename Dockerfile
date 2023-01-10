FROM --platform=$TARGETPLATFORM ubuntu:18.04

ARG TARGETOS
ARG TARGETARCH

# base
ENV DEBIAN_FRONTEND noninteractive TZ=Asia/Shanghai LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
ADD apt/$TARGETOS/$TARGETARCH/sources.list /etc/apt/sources.list
RUN chmod 644 /etc/apt/sources.list && apt-get update && mkdir /compiler && \
    apt-get install -y apt-utils openssl ca-certificates && \
    # user
    userdel -r www-data && useradd -rm -d /home/www -u 33 -U -s /bin/bash -G sudo -p "$(openssl passwd -1 www-data)" www-data && \
    useradd -rm -d /home/ubuntu -s /bin/bash -G sudo -p "$(openssl passwd -1 ubuntu)" ubuntu && \
    # build essential
    apt-get install -y vim wget curl iputils-ping build-essential sudo openssh-server dumb-init rsyslog cron net-tools supervisor && \
    apt-get install -y locales && locale-gen en_US.UTF-8 && \
    apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    # php
    apt-get install -y nginx php7.2-fpm php7.2-common php7.2-json php7.2-gd php7.2-cli php7.2-mbstring php7.2-xml \
    php7.2-opcache php7.2-mysql php7.2-curl php-redis php7.2-bcmath php7.2-zip php-sqlite3 && \
    # nginx & rsyslog logrotate & fix cron
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=726661
    # https://stackoverflow.com/questions/43323754/cannot-make-remove-an-entry-for-the-specified-session-cron
    sed -i 's+invoke-rc.d nginx rotate >/dev/null 2>&1+/etc/init.d/nginx rotate+' /etc/logrotate.d/nginx && \
    sed -i 's+/usr/lib/rsyslog/rsyslog-rotate+/etc/init.d/rsyslog rotate+' /etc/logrotate.d/rsyslog && \
    sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron && \
    sed -i '/session    required   pam_limits.so/c\#session    required   pam_limits.so' /etc/pam.d/cron

# compilers
ENV COMPILER_PATH=/compiler MINICONDA3_VERSION=py39_4.12.0 MINICONDA2_VERSION=py27_4.8.3 GOLANG_VERSION=1.19.3 NODE_VERSION=v16.18.0
COPY compilers/$TARGETOS/$TARGETARCH/install.sh /tmp/ 
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm -rf /tmp/* && rm -rf /var/lib/apt/lists/*

# setup
ENV PATH=${COMPILER_PATH}/miniconda3/bin:${COMPILER_PATH}/miniconda2/bin:${COMPILER_PATH}/go/bin:${COMPILER_PATH}/node/bin:${PATH}

ADD nginx/default /etc/nginx/sites-available/default
ADD requirements.txt /entrypoint/
COPY entrypoint.py /entrypoint/
COPY entrypoint.conf /etc/supervisor/conf.d/

RUN chmod 644 /etc/nginx/sites-available/default && \
    pip install -r /entrypoint/requirements.txt && \
    echo "export PATH=$PATH" >> /home/ubuntu/.bashrc && echo "export PATH=$PATH" >> /home/www/.bashrc

CMD ["dumb-init","/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]