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
GITHUB_REPO="泰拉瑞亚面板"
DOWNLOAD_URL="https://yourserver.com/releases/terrariaPanel_${VERSION}_linux_amd64.tar.gz"
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
    if command -v wget &> /dev/null; then
        wget -O "$TMP_DIR/panel.tar.gz" "$DOWNLOAD_URL"
    else
        curl -L -o "$TMP_DIR/panel.tar.gz" "$DOWNLOAD_URL"
    fi
    
    # 解压面板
    tar -xzf "$TMP_DIR/panel.tar.gz" -C "$TMP_DIR"
    
    # 移动文件
    cp "$TMP_DIR/$BIN_NAME" "$BIN_DIR/"
    chmod +x "$BIN_DIR/$BIN_NAME"
    
    # 移动配置文件(如果有)
    if [ -d "$TMP_DIR/config" ]; then
        cp -r "$TMP_DIR/config/"* "$CONFIG_DIR/"
    fi
    
    # 清理临时目录
    rm -rf "$TMP_DIR"
    
    echo -e "${GREEN}下载完成${NC}"
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
        nohup "$BIN_DIR/$BIN_NAME" -c -l "$PORT" -d "$DATA_DIR" > "$LOGS_DIR/panel.log" 2>&1 &
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
        wget -O "${SCRIPT_PATH}.new" "https://yourserver.com/releases/terraria_panel.sh"
    else
        curl -L -o "${SCRIPT_PATH}.new" "https://yourserver.com/releases/terraria_panel.sh"
    fi
    
    if [ -f "${SCRIPT_PATH}.new" ]; then
        chmod +x "${SCRIPT_PATH}.new"
        mv "${SCRIPT_PATH}.new" "$SCRIPT_PATH"
        echo -e "${GREEN}脚本更新完成${NC}"
    else
        echo -e "${RED}脚本下载失败${NC}"
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
    
    # 显示IP和端口
    echo -e "${BLUE}访问地址:${NC} http://$(hostname -I | awk '{print $1}'):$PORT"
}

# 显示菜单
show_menu() {
    clear
    echo -e "${BOLD}${GREEN}泰拉瑞亚服务器管理面板${NC}"
    echo -e "${BLUE}--- https://github.com/yourusername/terraria-panel ---${NC}"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[0]:${NC} 下载并启动服务(Download and start the service)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[1]:${NC} 启动服务(Start the service)"
    echo -e "${BOLD}[2]:${NC} 关闭服务(Stop the service)"
    echo -e "${BOLD}[3]:${NC} 重启服务(Restart the service)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[4]:${NC} 更新管理平台(Update management platform)"
    echo -e "${BOLD}[5]:${NC} 强制更新平台(Force update platform)"
    echo -e "${BOLD}[6]:${NC} 更新启动脚本(Update startup script)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BOLD}[7]:${NC} 设置虚拟内存(Setup swap)"
    echo -e "${BOLD}[8]:${NC} 查看面板状态(Show status)"
    echo -e "${BOLD}[9]:${NC} 退出脚本(Exit script)"
    echo -e "${YELLOW}————————————————————————————————————————————————————————————${NC}"
    
    read -p "请输入选择(Please enter your selection) [0-9]: " CHOICE
    
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
            update_panel
            ;;
        5)
            force_update
            ;;
        6)
            update_script
            ;;
        7)
            setup_swap
            ;;
        8)
            show_status
            ;;
        9)
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