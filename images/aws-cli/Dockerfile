FROM python:3.8.0a3-alpine3.9

ARG AWS_CLI_VERSION 1.16.140

RUN apk --no-cache update && \
    apk --no-cache add ca-certificates groff less jq openssh-client openssl docker curl && \
    pip3 --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

WORKDIR /data
ENTRYPOINT ["sh"]