# 多阶段构建 - 第一阶段：构建阶段
FROM 192.168.99.14:8101/node:22.22-alpine3.22 AS builder

# 设置工作目录
WORKDIR /app

# 安装系统依赖（用于编译原生模块）
# Python、make、g++ 是 node-gyp 编译原生模块所需
RUN apk add --no-cache python3 make g++ git openssh

# 复制 package.json 以利用 Docker 缓存层
COPY package*.json ./

# 设置 npm 配置（使用代理加速下载）
RUN npm config set proxy=http://192.168.96.18:7890 && \
    npm config set https-proxy=http://192.168.96.18:7890

# 安装生产依赖
RUN npm ci --only=production --unsafe-perm --no-update-notifier --no-fund || \
    npm install --only=production --unsafe-perm --no-update-notifier --no-fund

# 合并安装所有常用插件（减少层数）
RUN npm install \
    @ng-galien/node-red-pulsar@1.1.6 \
    node-red-contrib-cron-plus@2.1.0 \
    node-red-contrib-json-logic@2.0.1 \
    node-red-contrib-log-elk@1.3.2 \
    node-red-contrib-loop@1.0.1 \
    node-red-contrib-loop-processing@0.5.1 \
    node-red-contrib-oauth2@6.2.1 \
    node-red-contrib-postgresql@0.14.0 \
    node-red-contrib-redis@1.3.9 \
    node-red-contrib-socketio-server-jwt@1.1.5 \
    node-red-contrib-sse-client@0.2.4 \
    node-red-node-mysql@2.0.0 \
    --unsafe-perm --no-update-notifier --no-fund

# 创建 Node-RED 用户数据目录并安装全局库
# 注意：使用 /home/nodered/.node-red 以匹配 nodered 用户的家目录
RUN mkdir -p /home/nodered/.node-red && \
    cd /home/nodered/.node-red && \
    npm install \
    json-rules-engine@7.1.0 \
    dotenv@16.4.7 \
    path@0.12.7 \
    fs-extra@11.2.0 \
    dayjs@1.11.13 \
    flatted@3.3.3 \
    validate.js@0.13.1 \
    --unsafe-perm --no-update-notifier --no-fund

# 清理 npm 缓存和代理配置
RUN npm cache clean --force && \
    npm config delete proxy && \
    npm config delete https-proxy

# 第二阶段：运行时镜像
FROM 192.168.99.14:8101/node:22.22-alpine3.22

# 添加元数据标签
LABEL maintainer="Node-RED Team"
LABEL description="Optimized Node-RED with custom plugins"
LABEL version="4.1.10"

# 安装运行时所需的系统依赖
RUN apk add --no-cache git openssh

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 node_modules
COPY --from=builder /app/node_modules ./node_modules

# 从构建阶段复制 Node-RED 用户数据
COPY --from=builder /home/nodered/.node-red /home/nodered/.node-red

# 复制应用代码
COPY . .

# 创建非 root 用户以提高安全性
RUN addgroup -g 1001 -S nodered && \
    adduser -S nodered -u 1001 -G nodered && \
    chown -R nodered:nodered /app /home/nodered/.node-red && \
    chmod 644 /app/.env* 2>/dev/null || true

# 切换到非 root 用户
USER nodered

# 暴露默认端口
EXPOSE 1880

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:1880/ || exit 1

# 启动命令
ENTRYPOINT ["npm", "run", "start"]