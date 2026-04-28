ARG ACMEVERSION=latest
FROM neilpang/acme.sh:${ACMEVERSION}

RUN apk update -f && \
  apk --no-cache add -f docker-cli \
  rm -rf /var/cache/apk/*
