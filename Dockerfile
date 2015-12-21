FROM node:5
MAINTAINER jigsaw <m@jgs.me>

ADD . /app
RUN cd /app && npm install --production && npm run build:production

CMD ["/app/node_modules/.bin/lsc", "/app/src/server.ls"]
