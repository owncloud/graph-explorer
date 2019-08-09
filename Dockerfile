FROM node:10

WORKDIR /srv/grapi-explorer

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000
CMD [ "npm", "run", "serve"]