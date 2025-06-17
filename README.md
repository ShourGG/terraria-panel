# 泰拉瑞亚服务器管理面板

一个基于Web的泰拉瑞亚(Terraria)服务器管理面板，支持Linux系统管理和泰拉瑞亚服务器管理，类似于饥荒管理平台(DST Management Platform)。

## 功能特性

### 系统管理功能
- 系统信息监控：CPU、内存、磁盘、网络使用情况
- 进程管理：查看、结束进程
- 服务管理：启动、停止、重启系统服务
- 文件管理：浏览、编辑、上传、下载文件
- 命令执行：远程执行Linux命令

### 泰拉瑞亚服务器管理功能
- 服务器控制：启动、停止、重启泰拉瑞亚服务器
- 世界管理：创建、选择、删除世界
- 玩家管理：查看在线玩家、踢出、封禁玩家
- 服务器配置：修改服务器设置
- 备份管理：创建、恢复、删除世界备份
- 插件管理：启用/禁用插件、配置插件
- 服务器日志：实时查看服务器日志
- 服务器控制台：发送命令和消息

## 系统要求

- Linux操作系统 (推荐Ubuntu 20.04+, CentOS 7+)
- Node.js 16+ (自动安装)
- Mono运行时 (用于运行泰拉瑞亚服务器，自动安装)
- 最小配置: 1核CPU, 1GB内存, 5GB磁盘空间

## 快速安装

### 一键安装脚本
```bash
bash <(curl -s https://raw.githubusercontent.com/ShourGG/terraria-panel/main/terraria_panel.sh)
```

或者

```bash
bash <(wget -qO- https://raw.githubusercontent.com/ShourGG/terraria-panel/main/terraria_panel.sh)
```

### 手动安装
1. 下载安装脚本
```bash
wget https://raw.githubusercontent.com/ShourGG/terraria-panel/main/terraria_panel.sh
```

2. 添加执行权限
```bash
chmod +x terraria_panel.sh
```

3. 运行安装脚本
```bash
./terraria_panel.sh
```

## 使用方法

### 管理面板访问
安装完成后，可以通过以下地址访问管理面板：
```
http://服务器IP:端口
```
默认端口为80，可以在安装时或安装后修改。

### 默认账号
- 用户名：admin
- 密码：admin

首次登录后请立即修改默认密码。

### 管理泰拉瑞亚服务器
1. 在管理面板中，点击"泰拉瑞亚管理"菜单
2. 在服务器控制面板中，可以启动、停止、重启服务器
3. 可以创建新世界或选择已有世界
4. 可以管理玩家、配置服务器、查看日志等

### 管理Linux系统
1. 在管理面板中，点击"系统管理"菜单
2. 可以查看系统信息、管理进程和服务
3. 可以浏览和管理文件系统
4. 可以执行Linux命令

## 常见问题

### 无法访问管理面板
- 检查服务器防火墙是否开放了面板端口
- 检查服务是否正常运行：`systemctl status terraria-panel`
- 查看日志文件：`cat ~/terrariaPanel/logs/panel.log`

### 泰拉瑞亚服务器无法启动
- 检查Mono是否正确安装：`mono --version`
- 检查TShock文件是否完整
- 查看服务器日志：`cat ~/terrariaPanel/terraria/logs/server.log`

### 如何更新管理面板
运行安装脚本，选择"更新管理面板"选项：
```bash
./terraria_panel.sh
```

## 自定义配置

### 修改面板端口
1. 运行安装脚本：`./terraria_panel.sh`
2. 选择"修改面板端口"选项
3. 输入新端口号
4. 重启面板服务

### 修改泰拉瑞亚服务器配置
1. 在管理面板中，进入"泰拉瑞亚管理" > "服务器配置"
2. 修改配置参数
3. 保存并重启服务器

## 目录结构
- `~/terrariaPanel/bin`: 面板程序文件
- `~/terrariaPanel/config`: 配置文件
- `~/terrariaPanel/logs`: 日志文件
- `~/terrariaPanel/terraria`: 泰拉瑞亚服务器文件
  - `~/terrariaPanel/terraria/worlds`: 世界文件
  - `~/terrariaPanel/terraria/config`: 服务器配置
  - `~/terrariaPanel/terraria/logs`: 服务器日志

## 卸载
1. 运行安装脚本：`./terraria_panel.sh`
2. 选择"卸载管理面板"选项
3. 确认卸载

## 开发信息

### 技术栈
- 前端：Vue.js + Element Plus
- 后端：Node.js + Express
- 泰拉瑞亚服务器：TShock (基于Mono)

### 贡献
欢迎提交问题和功能请求，也欢迎贡献代码。

### 许可证
本项目采用 MIT 许可证。

## 致谢
- 感谢 [DST Management Platform](https://github.com/miracleEverywhere/dst-management-platform-api) 项目的灵感
- 感谢 [TShock](https://github.com/Pryaxis/TShock) 项目提供的泰拉瑞亚服务器框架
- 感谢 [KOI-UI](https://github.com/kuailemao/Koi-UI) 提供的前端框架