ARG JENKINS_VER=lts
ARG JENKINS_REGISTRY=jenkins/jenkins
FROM ${JENKINS_REGISTRY}:${JENKINS_VER}

# switch to root, let the entrypoint drop back to jenkins
USER root

# install prerequisite debian packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common \
     vim \
     wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install gosu for a better su+exec command
ARG GOSU_VERSION=1.10
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true 

# install docker
ARG DOCKER_CLI_VERSION==5:18.09.0~3-0~debian-stretch
# ARG DOCKER_CLI_VERSION=
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable" \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    docker-ce-cli${DOCKER_CLI_VERSION} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -r docker \
 && usermod -aG docker jenkins

# entrypoint is used to update docker gid and revert back to jenkins user
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD curl -sSLf http://localhost:8080/login >/dev/null || exit 1

ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_PATCH_VER=0
LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.cmd="docker run -d -p 8080:8080 -v \"$$(pwd)/jenkins-home:/var/jenkins_home\" -v /var/run/docker.sock:/var/run/docker.sock bmitch3020/jenkins-docker" \
    org.label-schema.description="Jenkins with docker support, Jenkins ${JENKINS_VER}, Docker ${DOCKER_VER}" \
    org.label-schema.name="bmitch3020/jenkins-docker" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/sudo-bmitch/jenkins-docker" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/sudo-bmitch/jenkins-docker" \
    org.label-schema.vendor="Brandon Mitchell" \
    org.label-schema.version="${JENKINS_VER}-${IMAGE_PATCH_VER}"

