#!/bin/bash

# 泰拉瑞亚服务器管理面板 - 一键安装脚本
# 参考DMP项目 https://github.com/miracleEverywhere/dst-management-platform-api

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # 恢复默认

# 配置信息
VERSION="1.0.0"
PORT=80
PANEL_NAME="terrariaPanel"
GITHUB_REPO="ShourGG/terraria-panel"
DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}/terraria-panel-linux.tar.gz"
BASE_DIR="$HOME/terrariaPanel"
BIN_DIR="$BASE_DIR/bin"
CONFIG_DIR="$BASE_DIR/config"
LOGS_DIR="$BASE_DIR/logs"
DATA_DIR="$BASE_DIR/data"
SERVICE_NAME="terraria-panel"
BIN_NAME="terraria-panel"

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${YELLOW}当前非root用户，部分功能可能受限${NC}"
    fi
}

# 创建必要目录
create_directories() {
    mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$LOGS_DIR" "$DATA_DIR"
    echo -e "${GREEN}目录创建完成${NC}"
}

# 检查依赖
check_dependencies() {
    echo -e "${BLUE}检查系统依赖...${NC}"
    
    # 检查wget或curl
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        echo -e "${YELLOW}未发现wget或curl，尝试安装wget${NC}"
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y wget
        elif command -v yum &> /dev/null; then
            yum install -y wget
        else
            echo -e "${RED}无法安装wget，请手动安装后重试${NC}"
            exit 1
        fi
    fi
    
    # 检查unzip
    if ! command -v unzip &> /dev/null; then
        echo -e "${YELLOW}未发现unzip，尝试安装${NC}"
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y unzip
        elif command -v yum &> /dev/null; then
            yum install -y unzip
        else
            echo -e "${RED}无法安装unzip，请手动安装后重试${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}系统依赖检查完成${NC}"
}

# 修改端口
change_port() {
    echo -e "${BLUE}当前端口: ${PORT}${NC}"
    read -p "请输入新的端口号(1-65535): " NEW_PORT
    
    if [[ "$NEW_PORT" =~ ^[0-9]+$ ]] && [ "$NEW_PORT" -ge 1 ] && [ "$NEW_PORT" -le 65535 ]; then
        PORT=$NEW_PORT
        echo -e "${GREEN}端口已修改为: ${PORT}${NC}"
        
        # 如果服务已经创建，需要更新服务配置
        if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ] && [ "$(id -u)" = "0" ]; then
            sed -i "s/-l [0-9]\+/-l $PORT/g" "/etc/systemd/system/${SERVICE_NAME}.service"
            systemctl daemon-reload
            echo -e "${GREEN}服务配置已更新${NC}"
        fi
        
        # 如果使用的是进程启动方式，则需要重启服务
        if [ -f "$BASE_DIR/panel.pid" ]; then
            restart_panel
        fi
    else
        echo -e "${RED}无效的端口号${NC}"
    fi
}

# 下载面板
download_panel() {
    echo -e "${BLUE}开始下载泰拉瑞亚管理面板...${NC}"
    
    if [ -f "$BIN_DIR/$BIN_NAME" ]; then
        echo -e "${YELLOW}检测到已存在的面板程序，将进行备份${NC}"
        mv "$BIN_DIR/$BIN_NAME" "$BIN_DIR/${BIN_NAME}_backup_$(date +%Y%m%d%H%M%S)"
    fi
    
    # 创建临时目录
    TMP_DIR=$(mktemp -d)
    
    # 下载面板
    echo -e "${BLUE}下载地址: ${DOWNLOAD_URL}${NC}"
    if command -v wget &> /dev/null; then
        wget -O "$TMP_DIR/panel.tar.gz" "$DOWNLOAD_URL"
    else
        curl -L -o "$TMP_DIR/panel.tar.gz" "$DOWNLOAD_URL"
    fi
    
    # 如果GitHub下载失败，使用备用方法创建一个简单的Node.js服务器程序
    if [ ! -s "$TMP_DIR/panel.tar.gz" ] || ! tar -tzf "$TMP_DIR/panel.tar.gz" &> /dev/null; then
        echo -e "${YELLOW}下载失败或文件不是有效的tar.gz格式，使用备用方法...${NC}"
        create_simple_server "$BIN_DIR/$BIN_NAME"
    else
        # 解压面板
        tar -xzf "$TMP_DIR/panel.tar.gz" -C "$TMP_DIR"
        
        # 移动文件
        cp "$TMP_DIR/$BIN_NAME" "$BIN_DIR/"
        chmod +x "$BIN_DIR/$BIN_NAME"
        
        # 移动配置文件(如果有)
        if [ -d "$TMP_DIR/config" ]; then
            cp -r "$TMP_DIR/config/"* "$CONFIG_DIR/"
        fi
    fi
    
    # 清理临时目录
    rm -rf "$TMP_DIR"
    
    echo -e "${GREEN}下载完成${NC}"
}

# 创建简单的Node.js服务器程序（备用方法）
create_simple_server() {
    local server_path=$1
    
    echo -e "${BLUE}创建简易服务器程序...${NC}"
    
    # 检查Node.js是否安装
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}未检测到Node.js，尝试安装...${NC}"
        if command -v apt-get &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
            apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
            yum install -y nodejs
        else
            echo -e "${RED}无法安装Node.js，请手动安装后重试${NC}"
            exit 1
        fi
    fi
    
    # 创建简单的Express服务器
    mkdir -p "$(dirname "$server_path")"
    cat > "$server_path" << 'EOF'
#!/usr/bin/env node

const http = require('http');
const os = require('os');
const { exec } = require('child_process');

const PORT = process.env.PORT || 80;

// 创建HTTP服务器
const server = http.createServer((req, res) => {
  if (req.url === '/') {
    // 首页
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>泰拉瑞亚服务器管理面板</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 20px; }
          h1 { color: #333; }
          .card { border: 1px solid #ddd; border-radius: 4px; padding: 15px; margin-bottom: 20px; }
          .info { display: flex; flex-wrap: wrap; }
          .info-item { flex: 1 1 200px; margin: 5px 0; }
          .label { font-weight: bold; }
          button { background: #4CAF50; color: white; border: none; padding: 10px 15px; border-radius: 4px; cursor: pointer; }
          button:hover { background: #45a049; }
          pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }
          .command-area { margin-top: 20px; }
          input[type="text"] { width: 70%; padding: 8px; margin-right: 10px; }
        </style>
      </head>
      <body>
        <h1>泰拉瑞亚服务器管理面板</h1>
        
        <div class="card">
          <h2>系统信息</h2>
          <div class="info">
            <div class="info-item"><span class="label">主机名:</span> ${os.hostname()}</div>
            <div class="info-item"><span class="label">系统:</span> ${os.type()} ${os.release()}</div>
            <div class="info-item"><span class="label">架构:</span> ${os.arch()}</div>
            <div class="info-item"><span class="label">CPU:</span> ${os.cpus()[0].model}</div>
            <div class="info-item"><span class="label">CPU核心数:</span> ${os.cpus().length}</div>
            <div class="info-item"><span class="label">总内存:</span> ${Math.round(os.totalmem() / (1024 * 1024 * 1024))} GB</div>
            <div class="info-item"><span class="label">可用内存:</span> ${Math.round(os.freemem() / (1024 * 1024 * 1024))} GB</div>
            <div class="info-item"><span class="label">运行时间:</span> ${Math.floor(os.uptime() / 3600)} 小时</div>
          </div>
        </div>
        
        <div class="card command-area">
          <h2>命令执行</h2>
          <form action="/execute" method="POST">
            <input type="text" name="command" placeholder="输入Linux命令...">
            <button type="submit">执行</button>
          </form>
          <div id="output"></div>
        </div>
        
        <script>
          document.querySelector('form').addEventListener('submit', async function(e) {
            e.preventDefault();
            const command = this.command.value;
            const outputDiv = document.getElementById('output');
            
            outputDiv.innerHTML = '<p>正在执行命令...</p>';
            
            try {
              const response = await fetch('/execute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command })
              });
              
              const result = await response.json();
              
              outputDiv.innerHTML = '<h3>命令输出:</h3><pre>' + 
                (result.stdout || '无输出') + 
                '</pre><h3>错误输出:</h3><pre>' + 
                (result.stderr || '无错误') + 
                '</pre>';
            } catch (error) {
              outputDiv.innerHTML = '<p>执行命令出错: ' + error.message + '</p>';
            }
          });
        </script>
      </body>
      </html>
    `);
  } else if (req.url === '/execute' && req.method === 'POST') {
    // 处理命令执行请求
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      let command;
      try {
        command = JSON.parse(body).command;
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '无效的请求' }));
        return;
      }
      
      // 安全检查
      const dangerousCommands = ['rm -rf /', 'mkfs', 'dd if=/dev/zero'];
      if (dangerousCommands.some(dc => command.includes(dc))) {
        res.writeHead(403, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: '禁止执行危险命令' }));
        return;
      }
      
      // 执行命令
      exec(command, { timeout: 30000 }, (error, stdout, stderr) => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          stdout: stdout || '',
          stderr: stderr || '',
          exitCode: error ? error.code : 0
        }));
      });
    });
  } else {
    // 404
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');
  }
});

// 启动服务器
server.listen(PORT, () => {
  console.log(`泰拉瑞亚管理面板服务器启动在端口 ${PORT}`);
  console.log(`访问地址: http://localhost:${PORT}`);
});

// 处理进程终止信号
process.on('SIGINT', () => {
  console.log('正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});
EOF
    
    chmod +x "$server_path"
    echo -e "${GREEN}简易服务器程序创建完成${NC}"
}

# 创建systemd服务
create_service() {
    echo -e "${BLUE}创建系统服务...${NC}"
    
    if [ "$(id -u)" != "0" ]; then
        echo -e "${YELLOW}非root用户，跳过服务创建，请手动启动面板${NC}"
        return
    fi
    
    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=Terraria Server Management Panel
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=$BIN_DIR/$BIN_NAME -c -l $PORT -d $DATA_DIR
WorkingDirectory=$BASE_DIR
Restart=on-failure
RestartSec=5s
LimitNOFILE=65535
Environment="PORT=$PORT"

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    echo -e "${GREEN}服务创建完成${NC}"
}

# 启动面板
start_panel() {
    echo -e "${BLUE}启动泰拉瑞亚管理面板...${NC}"
    
    if [ "$(id -u)" = "0" ]; then
        systemctl start "$SERVICE_NAME"
        sleep 2
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            echo -e "${GREEN}面板启动成功${NC}"
        else
            echo -e "${RED}面板启动失败，请查看日志${NC}"
        fi
    else
        # 确保环境变量被设置
        export PORT=$PORT
        
        nohup "$BIN_DIR/$BIN_NAME" > "$LOGS_DIR/panel.log" 2>&1 &
        sleep 2
        if ps -p $! > /dev/null; then
            echo $! > "$BASE_DIR/panel.pid"
            echo -e "${GREEN}面板启动成功，PID: $!${NC}"
        else
            echo -e "${RED}面板启动失败，请查看日志${NC}"
        fi
    fi
    
    echo -e "${BLUE}面板访问地址: ${BOLD}http://$(hostname -I | awk '{print $1}'):${PORT}${NC}"
}

# 停止面板
stop_panel() {
    echo -e "${BLUE}停止泰拉瑞亚管理面板...${NC}"
    
    if [ "$(id -u)" = "0" ]; then
        systemctl stop "$SERVICE_NAME"
        echo -e "${GREEN}面板已停止${NC}"
    else
        if [ -f "$BASE_DIR/panel.pid" ]; then
            PID=$(cat "$BASE_DIR/panel.pid")
            if ps -p "$PID" > /dev/null; then
                kill "$PID"
                echo -e "${GREEN}面板已停止，PID: $PID${NC}"
            else
                echo -e "${YELLOW}面板未运行${NC}"
            fi
            rm -f "$BASE_DIR/panel.pid"
        else
            PID=$(ps -ef | grep "$BIN_NAME" | grep -v grep | awk '{print $2}')
            if [ -n "$PID" ]; then
                kill "$PID"
                echo -e "${GREEN}面板已停止，PID: $PID${NC}"
            else
                echo -e "${YELLOW}面板未运行${NC}"
            fi
        fi
    fi
}

# 重启面板
restart_panel() {
    echo -e "${BLUE}重启泰拉瑞亚管理面板...${NC}"
    stop_panel
    sleep 2
    start_panel
}

# 更新面板
update_panel() {
    echo -e "${BLUE}更新泰拉瑞亚管理面板...${NC}"
    stop_panel
    download_panel
    start_panel
    echo -e "${GREEN}面板更新完成${NC}"
}

# 强制更新
force_update() {
    echo -e "${BLUE}强制更新泰拉瑞亚管理面板...${NC}"
    stop_panel
    # 备份配置
    if [ -d "$CONFIG_DIR" ]; then
        mkdir -p "$BASE_DIR/backup/config_$(date +%Y%m%d%H%M%S)"
        cp -r "$CONFIG_DIR/"* "$BASE_DIR/backup/config_$(date +%Y%m%d%H%M%S)/"
    fi
    # 备份数据
    if [ -d "$DATA_DIR" ]; then
        mkdir -p "$BASE_DIR/backup/data_$(date +%Y%m%d%H%M%S)"
        cp -r "$DATA_DIR/"* "$BASE_DIR/backup/data_$(date +%Y%m%d%H%M%S)/"
    fi
    # 删除旧文件
    rm -f "$BIN_DIR/$BIN_NAME"
    download_panel
    start_panel
    echo -e "${GREEN}面板强制更新完成${NC}"
}

# 更新脚本
update_script() {
    echo -e "${BLUE}更新启动脚本...${NC}"
    
    SCRIPT_PATH=$(readlink -f "$0")
    
    if command -v wget &> /dev/null; then
        wget -O "${SCRIPT_PATH}.new" "https://raw.githubusercontent.com/${GITHUB_REPO}/main/terraria_panel.sh"
    else
        curl -L -o "${SCRIPT_PATH}.new" "https://raw.githubusercontent.com/${GITHUB_REPO}/main/terraria_panel.sh"
    fi
    
    if [ -f "${SCRIPT_PATH}.new" ] && [ -s "${SCRIPT_PATH}.new" ]; then
        chmod +x "${SCRIPT_PATH}.new"
        mv "${SCRIPT_PATH}.new" "$SCRIPT_PATH"
        echo -e "${GREEN}脚本更新完成${NC}"
    else
        echo -e "${RED}脚本下载失败${NC}"
        rm -f "${SCRIPT_PATH}.new"
    fi
}

# 设置虚拟内存
setup_swap() {
    echo -e "${BLUE}设置虚拟内存...${NC}"
    
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}设置虚拟内存需要root权限${NC}"
        return
    fi
    
    # 检查是否已有swap
    if free | grep -q "Swap"; then
        SWAP_TOTAL=$(free | grep "Swap" | awk '{print $2}')
        if [ "$SWAP_TOTAL" -gt 0 ]; then
            echo -e "${YELLOW}系统已存在${SWAP_TOTAL}KB的虚拟内存${NC}"
            read -p "是否继续创建新的虚拟内存？(y/n): " CONTINUE
            if [ "$CONTINUE" != "y" ]; then
                return
            fi
        fi
    fi
    
    read -p "请输入要创建的虚拟内存大小(单位:MB，推荐1024): " SWAP_SIZE
    if [ -z "$SWAP_SIZE" ]; then
        SWAP_SIZE=1024
    fi
    
    # 创建swap文件
    echo -e "${BLUE}创建${SWAP_SIZE}MB的虚拟内存...${NC}"
    dd if=/dev/zero of=/swapfile bs=1M count="$SWAP_SIZE"
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # 设置开机自动挂载
    if ! grep -q "/swapfile" /etc/fstab; then
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi
    
    echo -e "${GREEN}虚拟内存设置完成${NC}"
}

# 显示面板状态
show_status() {
    echo -e "${BLUE}面板状态:${NC}"
    
    if [ "$(id -u)" = "0" ]; then
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            echo -e "${GREEN}运行中${NC}"
        else
            echo -e "${RED}未运行${NC}"
        fi
    else
        if [ -f "$BASE_DIR/panel.pid" ]; then
            PID=$(cat "$BASE_DIR/panel.pid")
            if ps -p "$PID" > /dev/null; then
                echo -e "${GREEN}运行中，PID: $PID${NC}"
            else
                echo -e "${RED}未运行${NC}"
            fi
        else
            PID=$(ps -ef | grep "$BIN_NAME" | grep -v grep | awk '{print $2}')
            if [ -n "$PID" ]; then
                echo -e "${GREEN}运行中，PID: $PID${NC}"
            else
                echo -e "${RED}未运行${NC}"
            fi
        fi
    fi
    
    # 显示版本信息
    if [ -f "$BIN_DIR/$BIN_NAME" ]; then
        echo -e "${BLUE}当前版本:${NC} $("$BIN_DIR/$BIN_NAME" -v 2>/dev/null || echo "未知")"
    else
        echo -e "${BLUE}当前版本:${NC} 未安装"
    fi
    
    # 显示端口
    echo -e "${BLUE}当前端口:${NC} $PORT"
    
    # 显示IP和端口
    echo -e "${BLUE}访问地址:${NC} http://$(hostname -I | awk '{print $1}'):$PORT"
}

# 显示菜单
show_menu() {
    clear
    echo -e "${BOLD}${GREEN}泰拉瑞亚服务器管理面板${NC}"
    echo -e "${BLUE}--- https://github.com/${GITHUB_REPO} ---${NC}"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[0]:${NC} 下载并启动服务(Download and start the service)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[1]:${NC} 启动服务(Start the service)"
    echo -e "${BOLD}[2]:${NC} 关闭服务(Stop the service)"
    echo -e "${BOLD}[3]:${NC} 重启服务(Restart the service)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[4]:${NC} 修改端口(Change port)"
    echo -e "${BOLD}[5]:${NC} 更新管理平台(Update management platform)"
    echo -e "${BOLD}[6]:${NC} 强制更新平台(Force update platform)"
    echo -e "${BOLD}[7]:${NC} 更新启动脚本(Update startup script)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[8]:${NC} 设置虚拟内存(Setup swap)"
    echo -e "${BOLD}[9]:${NC} 查看面板状态(Show status)"
    echo -e "${BOLD}[10]:${NC} 退出脚本(Exit script)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    
    read -p "请输入选择(Please enter your selection) [0-10]: " CHOICE
    
    case $CHOICE in
        0)
            check_dependencies
            create_directories
            download_panel
            create_service
            start_panel
            ;;
        1)
            start_panel
            ;;
        2)
            stop_panel
            ;;
        3)
            restart_panel
            ;;
        4)
            change_port
            ;;
        5)
            update_panel
            ;;
        6)
            force_update
            ;;
        7)
            update_script
            ;;
        8)
            setup_swap
            ;;
        9)
            show_status
            ;;
        10)
            echo -e "${GREEN}感谢使用，再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选择，请重新输入${NC}"
            ;;
    esac
    
    # 按任意键返回菜单
    read -n 1 -s -r -p "按任意键返回菜单..."
    show_menu
}

# 主函数
main() {
    check_root
    show_menu
}

# 执行主函数
main 