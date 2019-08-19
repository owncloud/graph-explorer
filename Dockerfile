#
# Copyright 2019 Kopano and its licensors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License, version 3 or
# later, as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM node:10 as builder
LABEL maintainer="development@kopano.io"

# Settings
ENV NO_UPDATE_NOTIFIER=1
ENV KWEBD_VERSION=0.7.0

WORKDIR /srv/grapi-explorer

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build:prod

RUN curl -sSL https://download.kopano.io/community/kweb:/kopano-kweb-${KWEBD_VERSION}.tar.gz | \
	tar -C /srv --strip 1 -vxzf -

FROM alpine:3.10

# Define basic environment variables.
ENV EXE=kwebd

# Defaults which can be overwritten.
ENV ARGS=""
ENV GRAPI_EXPLORER_CLIENT_ID=grapi-explorer.js
ENV GRAPI_EXPLORER_ISS=""
ENV GRAPI_EXPLORER_GRAPH_URL=""

EXPOSE 3000

RUN mkdir -p /srv/www/explorer
COPY util-scripts/Caddyfile.example /srv/Caddyfile

WORKDIR /srv

RUN ln -sv /tmp/secrets.js /srv/www/ && \
    ln -sv /tmp/config.js /srv/www/

COPY --from=builder \
    /srv/grapi-explorer/dist/ /srv/www/explorer/dist/
COPY --from=builder \
    /srv/grapi-explorer/src/custom.css \
    /srv/www/explorer/
COPY --from=builder /srv/grapi-explorer/src/index-aot.html /srv/www/explorer/index.html
COPY --from=builder /srv/grapi-explorer/node_modules/hellojs/dist/hello.all.js /srv/www/node_modules/hellojs/dist/
COPY --from=builder /srv/grapi-explorer/node_modules/moment/min/moment-with-locales.min.js /srv/www/node_modules/moment/min/
COPY --from=builder /srv/grapi-explorer/node_modules/core-js/client/shim.min.js /srv/www/node_modules/core-js/client/
COPY --from=builder /srv/grapi-explorer/node_modules/zone.js/dist/zone.js /srv/www/node_modules/zone.js/dist/
COPY --from=builder /srv/grapi-explorer/node_modules/systemjs/dist/system.src.js /srv/www/node_modules/systemjs/dist/
COPY --from=builder \
    /srv/grapi-explorer/config.sample.js \
    /srv/grapi-explorer/secrets.sample.js \
    /srv/
COPY --from=builder /srv/kwebd /usr/local/bin/

COPY util-scripts/docker-entrypoint.sh /usr/local/bin/

USER nobody:nogroup

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["serve"]