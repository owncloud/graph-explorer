FROM node:10

# Defaults which can be overwritten.
ENV ARGS=""
ENV GRAPI_EXPLORER_CLIENT_ID=grapi-explorer.js
ENV GRAPI_EXPLORER_ISS=""
ENV GRAPI_EXPLORER_GRAPH_URL=""

# NPM settings
env NO_UPDATE_NOTIFIER=1

WORKDIR /srv/grapi-explorer

COPY package*.json ./

RUN npm install

COPY . .

RUN ln -sv /tmp/secrets.js && ln -sv /tmp/config.js

USER nobody:nogroup

EXPOSE 3000

ENTRYPOINT ["/srv/grapi-explorer/util-scripts/docker-entrypoint.sh"]
CMD ["npm", "run", "serve"]