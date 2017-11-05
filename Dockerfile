FROM alpine:latest

ENV ARIA2_VERSION 1.32.0

ENV UID 1000
ENV GID 1000
ENV USER htpc
ENV GROUP htpc

RUN addgroup -S ${GROUP} -g ${GID} && adduser -D -S -u ${UID} ${USER} ${GROUP}  && \
    apk add --no-cache --virtual .build-deps curl git make g++ && \
    apk add --no-cache gnutls-dev expat-dev sqlite-dev c-ares-dev ca-certificates tzdata && \
    mkdir -p /tmp/aria2 && curl -sL https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}.tar.gz | tar xz -C /tmp/aria2 --strip-components=1 && \
    cd /tmp/aria2 && ./configure && make -j $(getconf _NPROCESSORS_ONLN) && make install && \
    apk del .build-deps && rm -rf /tmp/*

RUN mkdir -p /opt/downloads && touch /opt/test.conf &&  chown -R ${USER}:${GROUP}  /opt/ 

EXPOSE 6800

USER ${USER}

VOLUME /opt/downloads
VOLUME /opt/

LABEL version=${ARIA2_VERSION}
LABEL url=https://api.github.com/repos/aria2/aria2/releases/latest

CMD aria2c --conf-path=/opt/test.conf --enable-rpc=true --rpc-secret=${RPC_TOKEN} --rpc-listen-all=true -d /opt/downloads
