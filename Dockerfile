FROM 192.168.99.14:8101/node:18.17.1-alpine3.18
RUN mkdir -p /app
WORKDIR /app
COPY . ./
RUN npm config set proxy=http://192.168.96.18:7890
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production
# 常用插件安裝
RUN npm install @insectos/ssh-exec@0.3.2
RUN npm install @ng-galien/node-red-pulsar@1.1.6
RUN npm install node-red-contrib-cron-plus@2.1.0
RUN npm install node-red-contrib-json-logic@2.0.1
RUN npm install node-red-contrib-log-elk@1.3.2
RUN npm install node-red-contrib-loop@1.0.1
RUN npm install node-red-contrib-loop-processing@0.5.1
RUN npm install node-red-contrib-oauth2@6.2.1
RUN npm install node-red-contrib-postgresql@0.14.0
RUN npm install node-red-contrib-redis@1.3.9
RUN npm install node-red-contrib-socketio-server-jwt@1.1.5
RUN npm install node-red-contrib-sse-client@0.2.4
RUN npm install node-red-node-mysql@2.0.0
# 常用库的安装
WORKDIR /root/.node-red
RUN npm install json-rules-engine@7.1.0
RUN npm install dotenv@16.4.7
RUN npm install path@0.12.7
RUN npm install fs-extra@11.2.0
RUN npm install dayjs@1.11.13
RUN npm config delete proxy
# 操作系统安装
RUN export http_proxy=http://192.168.96.18:7890 && export https_proxy=http://192.168.96.18:7890 && \
    apk add git && \
    apk add openssh
RUN export http_proxy= && export https_proxy=
WORKDIR /app
ENTRYPOINT [ "npm","run","start" ]