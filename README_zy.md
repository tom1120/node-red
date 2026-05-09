
在用户目录.node-red下进行新的安装
新增MCP调用
npm install @modelcontextprotocol/sdk@1.12.3

新增私库节点
npm uninstall @ng-galien/node-red-pulsar    
npm --registry http://192.168.99.14:8081/repository/npm-public/ install --omit=dev  @ng-galien/node-red-pulsar@1.1.8 
npm install node-red@3.1.3