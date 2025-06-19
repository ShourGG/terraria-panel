FROM node:18-alpine

WORKDIR /app

COPY . .

RUN npm install && \
    mkdir -p dist && \
    cp -r dist/* dist/ && \
    chmod +x *.sh

EXPOSE 10788

CMD ["node", "server.js"] 