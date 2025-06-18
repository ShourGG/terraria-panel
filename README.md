# 泰拉瑞亚服务器管理面板

基于Koi-UI的泰拉瑞亚服务器管理面板，提供简单易用的Web界面来管理您的泰拉瑞亚服务器。

## 功能特点

* 美观现代的Koi-UI界面
* 服务器状态监控
* 服务器启动/停止/重启
* 玩家管理
* 控制台命令发送
* 日志查看
* TShock服务器文件上传和安装
* Linux系统监控

## 安装方法

### 方法一：一键安装脚本（5秒超时自动切换）

```bash
# 自动选择最快的源下载安装脚本（5秒超时自动切换）
curl -L --connect-timeout 5 "https://raw.githubusercontent.com/ShourGG/terraria-panel/koi-ui/install.sh" -o install.sh || curl -L --connect-timeout 5 "https://gitee.com/cd-writer/terraria-panel/raw/koi-ui/install.sh" -o install.sh
chmod +x install.sh
./install.sh
```

### 方法二：手动安装

1. 克隆仓库

```bash
# GitHub源
git clone -b koi-ui https://github.com/ShourGG/terraria-panel.git
# 或使用Gitee源（国内推荐）
git clone -b koi-ui https://gitee.com/cd-writer/terraria-panel.git
cd terraria-panel
```

2. 安装依赖

```bash
npm install
```

3. 启动服务

```bash
npm start
```

## 访问管理面板

安装完成后，访问 `http://服务器IP:10788` 即可打开管理面板。

## 系统要求

* Node.js 14.0 或更高版本
* Linux/Windows 操作系统
* 对于泰拉瑞亚服务器：Mono运行时环境

## 许可证

MIT