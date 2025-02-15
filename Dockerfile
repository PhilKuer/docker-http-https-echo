FROM node:14-alpine AS build

WORKDIR /app
COPY . /app

RUN set -ex \
  # Build JS-Application
  && npm install --production \
  # Generate SSL-certificate (for HTTPS)
  && apk --no-cache add openssl \
  && sh generate-cert.sh \
  && apk del openssl \
  && rm -rf /var/cache/apk/* \
  # Delete unnecessary files
  && rm package* generate-cert.sh \
  # Correct User's file access
  && chown -R node:node /app \
  && chgrp -R 0 /app \ 
  && chmod -R g=u /app

FROM node:14-alpine AS final
WORKDIR /app
COPY --from=build /app /app
ENV HTTP_PORT=8080 HTTPS_PORT=8443
EXPOSE $HTTP_PORT
EXPOSE $HTTPS_PORT
USER 1000
CMD ["node", "./index.js"]
