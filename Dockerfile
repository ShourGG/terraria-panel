FROM node:16-alpine AS build

WORKDIR /app

# 复制项目文件
COPY . .

# 安装依赖并构建前端
RUN npm install -g pnpm && \
    cd koi-ui-master && \
    pnpm install && \
    pnpm build && \
    cd .. && \
    mkdir -p dist && \
    cp -r koi-ui-master/dist/* dist/

# 安装生产依赖
RUN npm ci --only=production

# 最终镜像
FROM node:16-alpine

WORKDIR /app

# 复制构建结果
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/server.js ./server.js
COPY --from=build /app/package.json ./package.json

# 设置环境变量
ENV PORT=80
ENV NODE_ENV=production

# 暴露端口
EXPOSE 80

# 启动命令
CMD ["node", "server.js"] 