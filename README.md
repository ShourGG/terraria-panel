# 泰拉瑞亚服务器管理面板

一个简单的泰拉瑞亚服务器管理面板，提供基本的服务器管理功能。

## 主要功能

- 服务器状态监控
- 系统资源查看
- 进程管理
- 文件管理
- 服务控制

## 快速安装

使用以下命令一键安装：

```bash
# 从GitHub下载
wget https://raw.githubusercontent.com/ShourGG/terraria-panel/main/terraria_panel.sh && chmod +x terraria_panel.sh && ./terraria_panel.sh

# 如果GitHub访问困难，可以从Gitee下载
wget https://gitee.com/cd-writer/terraria-panel/raw/main/terraria_panel.sh && chmod +x terraria_panel.sh && ./terraria_panel.sh
```

## 使用说明

安装完成后，可以通过以下选项管理泰拉瑞亚服务器：

- `[0]`: 下载并启动服务
- `[1]`: 启动服务
- `[2]`: 关闭服务
- `[3]`: 重启服务
- `[4]`: 修改端口
- `[5]`: 更新管理平台
- `[6]`: 强制更新平台
- `[7]`: 更新启动脚本
- `[8]`: 设置虚拟内存
- `[9]`: 查看面板状态
- `[10]`: 退出脚本

## 下载源

本项目支持从多个源下载：

- GitHub: https://github.com/ShourGG/terraria-panel
- Gitee: https://gitee.com/cd-writer/terraria-panel

安装脚本会自动尝试从GitHub下载，如果失败则从Gitee下载。

## 系统要求

- Linux系统
- Node.js 12+
- 支持的Linux发行版: Ubuntu, Debian, CentOS, RHEL

## 常见问题排查

如果无法访问面板，请检查以下几点：

1. 确保防火墙允许访问面板端口
2. 如果使用云服务器，需要在控制台开放相应端口
3. 尝试使用HTTP而非HTTPS访问 (http://IP:端口)
4. 在访问链接中明确指定协议，例如 'http://'
5. 检查服务器是否有安全组或网络ACL限制
6. 尝试从服务器本地使用 curl http://localhost:端口 测试

## 许可证

MIT License

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

## 致谢

本项目前端基于[koi-ui](https://gitee.com/BigCatHome/koi-ui)开发，特此感谢！

安装脚本参考了[DMP](https://github.com/miracleEverywhere/dst-management-platform-api)项目的实现方式，感谢开源社区的贡献！ 