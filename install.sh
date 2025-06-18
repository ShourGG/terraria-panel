#!/bin/bash

# 泰拉瑞亚服务器管理面板 - 一键安装脚本
# Koi-UI版

# 全局变量
VERSION="1.0.0"
GITHUB_URL="https://raw.githubusercontent.com/ShourGG/terraria-panel/main"
GITEE_URL="https://gitee.com/cd-writer/terraria-panel/raw/main"
REPO_URL=""
BASE_DIR="$HOME/terrariaPanel"
CONFIG_DIR="$BASE_DIR/config"
LOGS_DIR="$BASE_DIR/logs"
PANEL_DIR="$BASE_DIR/panel"
TERRARIA_DIR="$BASE_DIR/terraria"
PORT=10788
LOG_FILE="$LOGS_DIR/panel.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m' # 恢复默认颜色

# 选择下载源
select_source() {
    echo -e "${BLUE}请选择下载源:${NC}"
    echo -e "1) GitHub (国际)"
    echo -e "2) Gitee (中国大陆)"
    
    read -p "请输入选项 [1-2，默认1]: " source_option
    
    case $source_option in
        2)
            REPO_URL=$GITEE_URL
            echo -e "${GREEN}已选择 Gitee 源${NC}"
            ;;
        *)
            REPO_URL=$GITHUB_URL
            echo -e "${GREEN}已选择 GitHub 源${NC}"
            ;;
    esac
}

# 创建必要目录
create_directories() {
    mkdir -p "$CONFIG_DIR" "$LOGS_DIR" "$PANEL_DIR" "$TERRARIA_DIR"
    echo -e "${GREEN}目录创建完成${NC}"
}

# 修改端口
change_port() {
    echo -e "${BLUE}当前端口: ${PORT}${NC}"
    read -p "请输入新的端口号(1-65535): " NEW_PORT
    
    if [[ "$NEW_PORT" =~ ^[0-9]+$ ]] && [ "$NEW_PORT" -ge 1 ] && [ "$NEW_PORT" -le 65535 ]; then
        PORT=$NEW_PORT
        echo -e "${GREEN}端口已修改为: ${PORT}${NC}"
    else
        echo -e "${RED}无效的端口号${NC}"
    fi
}

# 下载必要文件
download_files() {
    echo -e "${BLUE}开始下载必要文件...${NC}"
    
    # 创建dist目录
    mkdir -p "$PANEL_DIR/dist"
    
    # 下载server.js
    echo -e "${BLUE}下载server.js...${NC}"
    curl -s -L "$REPO_URL/server.js" -o "$PANEL_DIR/server.js" || {
        echo -e "${RED}下载server.js失败，尝试使用备用源...${NC}"
        # 尝试使用备用源
        if [ "$REPO_URL" = "$GITHUB_URL" ]; then
            curl -s -L "$GITEE_URL/server.js" -o "$PANEL_DIR/server.js"
        else
            curl -s -L "$GITHUB_URL/server.js" -o "$PANEL_DIR/server.js"
        fi
        
        # 如果仍然失败，创建基本文件
        if [ ! -s "$PANEL_DIR/server.js" ]; then
            echo -e "${RED}使用备用源下载失败，创建基本的server.js${NC}"
            create_basic_server
        fi
    }
    
    # 下载package.json
    echo -e "${BLUE}下载package.json...${NC}"
    curl -s -L "$REPO_URL/package.json" -o "$PANEL_DIR/package.json" || {
        echo -e "${RED}下载package.json失败，尝试使用备用源...${NC}"
        # 尝试使用备用源
        if [ "$REPO_URL" = "$GITHUB_URL" ]; then
            curl -s -L "$GITEE_URL/package.json" -o "$PANEL_DIR/package.json"
        else
            curl -s -L "$GITHUB_URL/package.json" -o "$PANEL_DIR/package.json"
        fi
        
        # 如果仍然失败，创建基本文件
        if [ ! -s "$PANEL_DIR/package.json" ]; then
            echo -e "${RED}使用备用源下载失败，创建基本的package.json${NC}"
            create_basic_package
        fi
    }
    
    # 下载前端文件
    echo -e "${BLUE}下载前端文件...${NC}"
    TMP_DIR=$(mktemp -d)
    
    # 尝试下载dist目录
    curl -s -L "$REPO_URL/dist/index.html" -o "$PANEL_DIR/dist/index.html" || {
        echo -e "${YELLOW}下载index.html失败，尝试使用备用源...${NC}"
        
        # 尝试使用备用源
        if [ "$REPO_URL" = "$GITHUB_URL" ]; then
            curl -s -L "$GITEE_URL/dist/index.html" -o "$PANEL_DIR/dist/index.html"
        else
            curl -s -L "$GITHUB_URL/dist/index.html" -o "$PANEL_DIR/dist/index.html"
        fi
        
        if [ ! -s "$PANEL_DIR/dist/index.html" ]; then
            echo -e "${YELLOW}使用备用源下载失败，尝试下载整个前端包${NC}"
            
            # 尝试下载前端包
            if [ "$REPO_URL" = "$GITHUB_URL" ]; then
                curl -s -L "$REPO_URL/terraria_panel_frontend.zip" -o "$TMP_DIR/frontend.zip" || \
                curl -s -L "$GITEE_URL/terraria_panel_frontend.zip" -o "$TMP_DIR/frontend.zip"
            else
                curl -s -L "$REPO_URL/terraria_panel_frontend.zip" -o "$TMP_DIR/frontend.zip" || \
                curl -s -L "$GITHUB_URL/terraria_panel_frontend.zip" -o "$TMP_DIR/frontend.zip"
            fi
            
            if [ -f "$TMP_DIR/frontend.zip" ] && [ -s "$TMP_DIR/frontend.zip" ]; then
                echo -e "${BLUE}解压前端文件...${NC}"
                unzip -q "$TMP_DIR/frontend.zip" -d "$TMP_DIR"
                cp -r "$TMP_DIR/dist"/* "$PANEL_DIR/dist/"
            else
                echo -e "${RED}下载前端文件失败，创建基本的前端文件${NC}"
                create_basic_html
            fi
        fi
    }
    
    # 清理临时文件
    rm -rf "$TMP_DIR"
    
    echo -e "${GREEN}文件下载完成${NC}"
}

# 创建基本的server.js
create_basic_server() {
    echo -e "${YELLOW}创建基本的server.js...${NC}"
    cat > "$PANEL_DIR/server.js" << EOF
const express = require('express');
const path = require('path');
const fs = require('fs');
const os = require('os');
const app = express();
const port = process.env.PORT || $PORT;

// 静态文件服务
app.use(express.static(path.join(__dirname, 'dist')));
app.use(express.json());

// API路由
app.get('/api/status', (req, res) => {
  res.json({
    status: 'running',
    version: '1.0.0',
    uptime: Math.floor(process.uptime()),
    memory: process.memoryUsage().rss / 1024 / 1024
  });
});

// 启动服务器
app.listen(port, () => {
  console.log(\`泰拉瑞亚服务器管理面板正在运行，端口: \${port}\`);
});
EOF
}

# 创建基本的index.html
create_basic_html() {
    echo -e "${YELLOW}创建基本的index.html...${NC}"
    cat > "$PANEL_DIR/dist/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>泰拉瑞亚服务器管理面板</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
    .container { max-width: 800px; margin: 0 auto; }
    .card { background: white; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 20px; }
    .card-title { font-size: 18px; font-weight: bold; margin-bottom: 15px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>泰拉瑞亚服务器管理面板</h1>
    <div class="card">
      <div class="card-title">服务器状态</div>
      <p>简易版面板已启动</p>
      <p>请访问 GitHub 获取完整版: <a href="https://github.com/ShourGG/terraria-panel">https://github.com/ShourGG/terraria-panel</a></p>
      <p>国内镜像: <a href="https://gitee.com/cd-writer/terraria-panel">https://gitee.com/cd-writer/terraria-panel</a></p>
    </div>
  </div>
</body>
</html>
EOF
}

# 创建基本的package.json
create_basic_package() {
    echo -e "${YELLOW}创建基本的package.json...${NC}"
    cat > "$PANEL_DIR/package.json" << EOF
{
  "name": "terraria-panel",
  "version": "1.0.0",
  "description": "泰拉瑞亚服务器管理面板",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF
}

# 安装依赖
install_dependencies() {
    echo -e "${BLUE}安装Node.js依赖...${NC}"
    
    # 检查是否安装了npm
    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}未发现npm，尝试安装Node.js...${NC}"
        
        # 尝试安装Node.js
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y nodejs npm
        elif command -v yum &> /dev/null; then
            yum install -y nodejs npm
        else
            echo -e "${RED}无法安装Node.js，请手动安装后重试${NC}"
            exit 1
        fi
    fi
    
    # 安装依赖
    cd "$PANEL_DIR"
    npm install --production
    
    echo -e "${GREEN}依赖安装完成${NC}"
}

# 创建启动脚本
create_start_script() {
    echo -e "${BLUE}创建启动脚本...${NC}"
    
    cat > "$BASE_DIR/start.sh" << EOF
#!/bin/bash
cd "$PANEL_DIR"
PORT=$PORT node server.js > "$LOG_FILE" 2>&1 &
echo \$! > "$BASE_DIR/panel.pid"
echo "泰拉瑞亚管理面板已启动，端口: $PORT"
EOF

    chmod +x "$BASE_DIR/start.sh"
    
    cat > "$BASE_DIR/stop.sh" << EOF
#!/bin/bash
if [ -f "$BASE_DIR/panel.pid" ]; then
    PID=\$(cat "$BASE_DIR/panel.pid")
    if ps -p \$PID > /dev/null; then
        kill \$PID
        echo "泰拉瑞亚管理面板已停止"
    else
        echo "面板进程不存在"
    fi
    rm "$BASE_DIR/panel.pid"
else
    echo "找不到面板PID文件"
fi
EOF

    chmod +x "$BASE_DIR/stop.sh"
    
    echo -e "${GREEN}启动脚本创建完成${NC}"
}

# 启动面板
start_panel() {
    echo -e "${BLUE}启动泰拉瑞亚管理面板...${NC}"
    
    "$BASE_DIR/start.sh"
    
    echo -e "${GREEN}面板已启动，请访问: http://localhost:$PORT${NC}"
    echo -e "${GREEN}如果是远程服务器，请访问: http://服务器IP:$PORT${NC}"
    echo -e "${YELLOW}日志文件位置: $LOG_FILE${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}=== 泰拉瑞亚服务器管理面板安装脚本 v$VERSION ===${NC}"
    
    # 创建目录
    create_directories
    
    # 选择下载源
    select_source
    
    # 询问是否修改端口
    read -p "是否修改默认端口 $PORT? (y/n): " change_port_answer
    if [[ "$change_port_answer" == "y" || "$change_port_answer" == "Y" ]]; then
        change_port
    fi
    
    # 下载文件
    download_files
    
    # 安装依赖
    install_dependencies
    
    # 创建启动脚本
    create_start_script
    
    # 询问是否立即启动
    read -p "是否立即启动面板? (y/n): " start_now
    if [[ "$start_now" == "y" || "$start_now" == "Y" ]]; then
        start_panel
    else
        echo -e "${BLUE}安装完成，使用以下命令启动面板:${NC}"
        echo -e "${GREEN}$BASE_DIR/start.sh${NC}"
    fi
    
    echo -e "${BLUE}=== 安装完成 ===${NC}"
}

# 执行主函数
main 