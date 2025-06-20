FROM node:18

WORKDIR /app

COPY . .

RUN npm install && \
    mkdir -p public && \
    cp -r public/* public/ && \
    npm prune --production

EXPOSE 10788

CMD ["node", "server.js"] 