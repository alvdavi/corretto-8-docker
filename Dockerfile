FROM amazonlinux:2

# x86_64 args
ARG rpm_x64=java-1.8.0-amazon-corretto-devel-1.8.0_242.b07-1.x86_64.rpm
ARG path_x64=https://corretto.aws/downloads/resources/8.242.07.1
ARG key_x64=6DC3636DAE534049C8B94623A122542AB04F24E3

# aarch64 args
ARG rpm_aarch64=java-1.8.0-amazon-corretto-devel-1.8.0_242.b07-1.amzn2.aarch64.rpm
ARG path_aarch64=https://corretto.aws/downloads/resources/8.242.07.1
ARG key_aarch64=6DC3636DAE534049C8B94623A122542AB04F24E3
# In addition to installing the RPM, we also install
# fontconfig. The folks who manage the docker hub's
# official image library have found that font management
# is a common usecase, and painpoint, and have
# recommended that Java images include font support.
#
# See:
#  https://github.com/docker-library/official-images/blob/master/test/tests/java-uimanager-font/container.java


RUN set -eux; \
    case "$(uname -p)" in \
        x86_64) rpm=$rpm_x64; path=$path_x64; key=$key_x64 ;; \
        aarch64) rpm=$rpm_aarch64; path=$path_aarch64; key=$key_aarch64 ;; \
        *) echo >&2 "Unsupported architecture $(uname -p)."; exit 1 ;; \
    esac; \
    \
    curl -O $path/$rpm \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys $key \
    && gpg --armor --export $key > corretto.asc \
    && rpm --import corretto.asc \
    && rpm -K $rpm \
    && rpm -i $rpm \
    && rm -r $GNUPGHOME corretto.asc $rpm \
    && yum install -y fontconfig \
    && yum clean all

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
