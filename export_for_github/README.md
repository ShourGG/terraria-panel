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
wget https://gitee.com/ShourGG/terraria-panel/raw/main/terraria_panel.sh && chmod +x terraria_panel.sh && ./terraria_panel.sh
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
- Gitee: https://gitee.com/ShourGG/terraria-panel

安装脚本会自动尝试从GitHub下载，如果失败则从Gitee下载。

## 系统要求

- Linux系统
- Node.js 12+
- 支持的Linux发行版: Ubuntu, Debian, CentOS, RHEL

## 许可证

MIT License

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