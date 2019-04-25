FROM centos:7

ENV ZK_USER=zookeeper \
    ZK_DATA_DIR=/var/lib/zookeeper/data \
    ZK_DATA_LOG_DIR=/var/lib/zookeeper/log \
    ZK_LOG_DIR=/var/log/zookeeper \
    JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk

ARG GPG_KEY=3F7A1D16FA4217B1DC75E1C9FFE35B7F15DFA1BA         
ARG ZK_DIST=zookeeper-3.4.14

RUN set -x && \
    yum install -y java-1.8.0-openjdk-headless.x86_64 wget nmap-ncat.x86_64 && \
    wget -q "http://www.apache.org/dist/zookeeper/$ZK_DIST/$ZK_DIST.tar.gz" && \
    wget -q "http://www.apache.org/dist/zookeeper/$ZK_DIST/$ZK_DIST.tar.gz.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver pgpkeys.mit.edu --recv-key "$GPG_KEY" && \
    gpg --batch --verify "$ZK_DIST.tar.gz.asc" "$ZK_DIST.tar.gz" && \
    tar -xzf "$ZK_DIST.tar.gz" -C /opt && \
    rm -r "$GNUPGHOME" "$ZK_DIST.tar.gz" "$ZK_DIST.tar.gz.asc" && \
    ln -s /opt/$ZK_DIST /opt/zookeeper && \
    rm -rf /opt/zookeeper/README.md \
           /opt/zookeeper/NOTICE.txt \
           /opt/zookeeper/README_packaging.txt \
           /opt/zookeeper/build.xml \
           /opt/zookeeper/zookeeper-contrib \
           /opt/zookeeper/dist-maven \
           /opt/zookeeper/zookeeper-docs \
           /opt/zookeeper/ivy.xml \
           /opt/zookeeper/ivysettings.xml \
           /opt/zookeeper/zookeeper-recipes \
           /opt/zookeeper/src \
           /opt/zookeeper/$ZK_DIST.jar.asc \
           /opt/zookeeper/$ZK_DIST.jar.md5 \
           /opt/zookeeper/$ZK_DIST.jar.sha1 && \
    yum autoremove -y wget && \
    yum clean all

# Copy configuration generator script to bin
COPY zkGenConfig.sh zkOk.sh zkMetrics.sh /opt/zookeeper/bin/

# Create a user for the zookeeper process and configure file system ownership
# for necessary directories and symlink the distribution as a user executable
RUN set -x \
    && useradd $ZK_USER \
    && [ `id -u $ZK_USER` -eq 1000 ] \
    && [ `id -g $ZK_USER` -eq 1000 ] \
    && mkdir -p $ZK_DATA_DIR $ZK_DATA_LOG_DIR $ZK_LOG_DIR /usr/share/zookeeper /tmp/zookeeper /usr/etc/ \
    && chown -R "$ZK_USER:$ZK_USER" /opt/$ZK_DIST $ZK_DATA_DIR $ZK_LOG_DIR $ZK_DATA_LOG_DIR /tmp/zookeeper \
    && ln -s /opt/zookeeper/conf/ /usr/etc/zookeeper \
    && ln -s /opt/zookeeper/bin/* /usr/bin \
    && ln -s /opt/zookeeper/$ZK_DIST.jar /usr/share/zookeeper/ \
    && ln -s /opt/zookeeper/lib/* /usr/share/zookeeper