FROM jenkins:latest

ARG GOSU_VERSION=1.10

# switch to root, let the entrypoint drop back to jenkins
USER root

# install other Debian convenience packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     vim \
     wget \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true \
 && curl -sSL https://get.docker.com/ | sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# switching to jenkins user is moved into the entrypoint
# USER jenkins
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# install plugins
#RUN install-plugins.sh  \

  #blueocean \
  #disable-failed-job \
  #disk-usage \
  #docker-plugin \
  #docker-workflow \
  #github-pullrequest \
  #gitlab-plugin \
  #monitoring \
  #postbuild-task \
  #role-strategy \
  #tasks \
  #workflow-aggregator \

