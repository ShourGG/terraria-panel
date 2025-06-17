# 泰拉瑞亚服务器管理面板

一个简单易用的泰拉瑞亚服务器管理面板，支持通过网页界面远程管理Linux服务器。

## 功能特点

- 系统监控：CPU、内存、磁盘使用率实时监控
- 进程管理：查看和管理系统进程
- 服务管理：控制系统服务的启动、停止和重启
- 文件管理：浏览、编辑、创建和删除文件
- 命令执行：在Web界面执行Linux命令
- 一键安装：提供简单的安装脚本，一键部署

## 安装方法

### 使用一键安装脚本（推荐）

```bash
# 下载安装脚本
wget https://raw.githubusercontent.com/yourusername/terraria-panel/main/terraria_panel.sh

# 设置执行权限
chmod +x terraria_panel.sh

# 运行脚本
./terraria_panel.sh
```

按照脚本提示选择选项0，即可完成下载和安装。

### 手动安装

如果您想手动安装，可以按照以下步骤操作：

1. 克隆仓库：
   ```bash
   git clone https://github.com/yourusername/terraria-panel.git
   cd terraria-panel
   ```

2. 安装依赖并构建：
   ```bash
   npm install
   npm run build
   ```

3. 启动服务：
   ```bash
   npm start
   ```

## 使用方法

1. 安装完成后，通过浏览器访问 `http://服务器IP地址:80`
2. 使用系统监控、进程管理、服务管理、文件管理等功能

## 系统要求

- Linux系统（推荐Ubuntu 20.04或更高版本）
- Node.js 14+（如使用一键安装脚本则无需手动安装）
- 1GB以上内存
- 公网IP（如需远程访问）

## 开发说明

### 项目结构

```
terraria-panel/
├── dist/             # 前端构建输出
├── koi-ui-master/    # 前端源码
├── server.js         # 后端服务器
├── package.json      # 项目配置
├── terraria_panel.sh # 安装脚本
└── README.md         # 项目说明
```

### 构建前端

```bash
cd koi-ui-master
pnpm install
pnpm build
```

### 打包为可执行文件

```bash
npm run pkg
```

这将在bin目录下生成Linux可执行文件。

## 注意事项

- 面板默认监听80端口，可通过环境变量PORT修改
- 为安全起见，建议配置防火墙只允许特定IP访问
- 某些功能需要root权限才能正常使用

## 许可证

MIT

## 致谢

本项目前端基于[koi-ui](https://gitee.com/BigCatHome/koi-ui)开发，特此感谢！

安装脚本参考了[DMP](https://github.com/miracleEverywhere/dst-management-platform-api)项目的实现方式，感谢开源社区的贡献！ 