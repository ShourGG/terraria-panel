#!/bin/bash

# 泰拉瑞亚服务器管理面板 - 一键安装脚本
# Koi-UI版

# 全局变量
VERSION="1.0.8"  # 增加版本号
GITHUB_REPO="https://github.com/ShourGG/terraria-panel.git"
GITEE_REPO="https://gitee.com/cd-writer/terraria-panel.git"
GITHUB_SCRIPT_URL="https://raw.githubusercontent.com/ShourGG/terraria-panel/koi-ui/install.sh"
GITEE_SCRIPT_URL="https://gitee.com/cd-writer/terraria-panel/raw/koi-ui/install.sh"
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

# 清屏函数
clear_screen() {
    clear
}

# 显示菜单
show_menu() {
    clear_screen
    echo -e "${BLUE}泰拉瑞亚服务器管理平台(Terraria Management Platform) v${VERSION}${NC}"
    echo -e "${BLUE}--- https://github.com/ShourGG/terraria-panel ---${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}[0]: 下载并启动服务(Download and start the service)${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}[1]: 启动服务(Start the service)${NC}"
    echo -e "${BLUE}[2]: 关闭服务(Stop the service)${NC}"
    echo -e "${BLUE}[3]: 重启服务(Restart the service)${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}[4]: 更新管理平台(Update management platform)${NC}"
    echo -e "${BLUE}[5]: 强制更新平台(Force update platform)${NC}"
    echo -e "${BLUE}[6]: 修改面板端口(Change panel port)${NC}"
    echo -e "${BLUE}[7]: 更新启动脚本(Update startup script)${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}[8]: 设置虚拟内存(Setup swap)${NC}"
    echo -e "${BLUE}[9]: 退出脚本(Exit script)${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${YELLOW}请输入选择(Please enter your selection) [0-9]:${NC}"
}

# 选择下载源
select_source() {
    echo -e "${BLUE}请选择下载源:${NC}"
    echo -e "1) GitHub (国际)"
    echo -e "2) Gitee (中国大陆)"
    echo -e "3) 自动选择 (推荐)"
    
    read -p "请输入选项 [1-3，默认3]: " source_option
    
    case $source_option in
        1)
            REPO_URL=$GITHUB_REPO
            echo -e "${GREEN}已选择 GitHub 源${NC}"
            ;;
        2)
            REPO_URL=$GITEE_REPO
            echo -e "${GREEN}已选择 Gitee 源${NC}"
            ;;
        *)
            echo -e "${BLUE}自动选择最快的源...${NC}"
            # 测试GitHub连接速度
            start_time=$(date +%s%N)
            git ls-remote --exit-code --heads $GITHUB_REPO koi-ui &>/dev/null
            github_status=$?
            end_time=$(date +%s%N)
            github_time=$((($end_time - $start_time)/1000000))
            
            # 测试Gitee连接速度
            start_time=$(date +%s%N)
            git ls-remote --exit-code --heads $GITEE_REPO koi-ui &>/dev/null
            gitee_status=$?
            end_time=$(date +%s%N)
            gitee_time=$((($end_time - $start_time)/1000000))
            
            # 根据连接状态和速度选择源
            if [ $github_status -eq 0 ] && [ $gitee_status -eq 0 ]; then
                # 两个源都可用，选择更快的
                if [ $github_time -lt $gitee_time ]; then
                    REPO_URL=$GITHUB_REPO
                    echo -e "${GREEN}已自动选择 GitHub 源 (响应时间: ${github_time}ms)${NC}"
                else
                    REPO_URL=$GITEE_REPO
                    echo -e "${GREEN}已自动选择 Gitee 源 (响应时间: ${gitee_time}ms)${NC}"
                fi
            elif [ $github_status -eq 0 ]; then
                # 只有GitHub可用
                REPO_URL=$GITHUB_REPO
                echo -e "${GREEN}已自动选择 GitHub 源${NC}"
            elif [ $gitee_status -eq 0 ]; then
                # 只有Gitee可用
                REPO_URL=$GITEE_REPO
                echo -e "${GREEN}已自动选择 Gitee 源${NC}"
            else
                # 两个源都不可用，默认使用GitHub
                REPO_URL=$GITHUB_REPO
                echo -e "${YELLOW}两个源都不可用，默认使用 GitHub 源${NC}"
            fi
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
        # 检查端口是否被占用
        if command -v lsof &> /dev/null; then
            # 使用lsof检查端口占用（Linux/macOS）
            PORT_PID=$(lsof -ti:$NEW_PORT)
            if [ -n "$PORT_PID" ]; then
                echo -e "${YELLOW}警告: 端口 $NEW_PORT 已被进程 $PORT_PID 占用${NC}"
                read -p "是否终止该进程并使用此端口? [y/N]: " kill_process
                if [[ "$kill_process" =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}正在终止进程 $PORT_PID...${NC}"
                    kill -9 $PORT_PID
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}进程已终止${NC}"
                    else
                        echo -e "${RED}无法终止进程，请尝试使用其他端口${NC}"
                        return 1
                    fi
                else
                    echo -e "${YELLOW}已取消端口修改${NC}"
                    return 1
                fi
            fi
        elif command -v netstat &> /dev/null; then
            # 使用netstat检查端口占用（Windows/Linux）
            if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "win32" ]; then
                # Windows系统
                PORT_INFO=$(netstat -ano | grep -E "TCP|UDP" | grep -E ":$NEW_PORT\s")
                if [ -n "$PORT_INFO" ]; then
                    PORT_PID=$(echo "$PORT_INFO" | awk '{print $5}')
                    echo -e "${YELLOW}警告: 端口 $NEW_PORT 已被进程 $PORT_PID 占用${NC}"
                    read -p "是否终止该进程并使用此端口? [y/N]: " kill_process
                    if [[ "$kill_process" =~ ^[Yy]$ ]]; then
                        echo -e "${YELLOW}正在终止进程 $PORT_PID...${NC}"
                        taskkill /F /PID $PORT_PID
                        if [ $? -eq 0 ]; then
                            echo -e "${GREEN}进程已终止${NC}"
                        else
                            echo -e "${RED}无法终止进程，请尝试使用其他端口${NC}"
                            return 1
                        fi
                    else
                        echo -e "${YELLOW}已取消端口修改${NC}"
                        return 1
                    fi
                fi
            else
                # Linux系统使用netstat
                PORT_INFO=$(netstat -tuln | grep ":$NEW_PORT\s")
                if [ -n "$PORT_INFO" ]; then
                    # 尝试找到占用端口的进程
                    PORT_PID=$(netstat -tulnp 2>/dev/null | grep ":$NEW_PORT\s" | awk '{print $7}' | cut -d'/' -f1)
                    if [ -n "$PORT_PID" ]; then
                        echo -e "${YELLOW}警告: 端口 $NEW_PORT 已被进程 $PORT_PID 占用${NC}"
                        read -p "是否终止该进程并使用此端口? [y/N]: " kill_process
                        if [[ "$kill_process" =~ ^[Yy]$ ]]; then
                            echo -e "${YELLOW}正在终止进程 $PORT_PID...${NC}"
                            kill -9 $PORT_PID
                            if [ $? -eq 0 ]; then
                                echo -e "${GREEN}进程已终止${NC}"
                            else
                                echo -e "${RED}无法终止进程，请尝试使用其他端口${NC}"
                                return 1
                            fi
                        else
                            echo -e "${YELLOW}已取消端口修改${NC}"
                            return 1
                        fi
                    else
                        echo -e "${YELLOW}警告: 端口 $NEW_PORT 已被占用，但无法确定进程ID${NC}"
                        read -p "是否继续使用此端口? [y/N]: " continue_use
                        if [[ ! "$continue_use" =~ ^[Yy]$ ]]; then
                            echo -e "${YELLOW}已取消端口修改${NC}"
                            return 1
                        fi
                    fi
                fi
            fi
        else
            echo -e "${YELLOW}无法检查端口占用情况，请确保端口 $NEW_PORT 未被使用${NC}"
        fi
        
        PORT=$NEW_PORT
        echo -e "${GREEN}端口已修改为: ${PORT}${NC}"
        
        # 如果配置文件存在，更新端口配置
        if [ -f "$CONFIG_DIR/config.json" ]; then
            # 尝试使用jq更新配置
            if command -v jq &> /dev/null; then
                jq ".port = $PORT" "$CONFIG_DIR/config.json" > "$CONFIG_DIR/config.json.tmp" && mv "$CONFIG_DIR/config.json.tmp" "$CONFIG_DIR/config.json"
                echo -e "${GREEN}配置文件已更新${NC}"
            else
                echo -e "${YELLOW}未安装jq工具，无法自动更新配置文件${NC}"
                echo -e "${YELLOW}请手动编辑 $CONFIG_DIR/config.json 文件修改端口${NC}"
            fi
        else
            # 创建配置目录和配置文件
            mkdir -p "$CONFIG_DIR"
            echo "{\"port\": $PORT}" > "$CONFIG_DIR/config.json"
            echo -e "${GREEN}已创建配置文件${NC}"
        fi
    else
        echo -e "${RED}无效的端口号${NC}"
    fi
}

# 下载面板文件
download_panel() {
    echo -e "${BLUE}开始下载泰拉瑞亚服务器管理面板...${NC}"
    
    # 检查是否安装了git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}未安装Git，请先安装Git${NC}"
        echo -e "${YELLOW}Debian/Ubuntu: apt-get install git${NC}"
        echo -e "${YELLOW}CentOS/RHEL: yum install git${NC}"
        return 1
    fi
    
    # 创建临时目录
    TMP_DIR=$(mktemp -d)
    CURRENT_DIR=$(pwd)
    
    # 切换到临时目录
    cd "$TMP_DIR" || { echo -e "${RED}无法切换到临时目录${NC}"; return 1; }
    
    # 克隆仓库
    echo -e "${BLUE}从${REPO_URL}克隆Koi-UI分支...${NC}"
    if git clone --depth=1 -b koi-ui "$REPO_URL" "$TMP_DIR/repo"; then
        echo -e "${GREEN}克隆成功${NC}"
        
        # 检查是否包含public目录
        if [ -d "$TMP_DIR/repo/public" ]; then
            echo -e "${BLUE}复制文件到面板目录...${NC}"
            
            # 创建面板目录（如果不存在）
            mkdir -p "$PANEL_DIR"
            
            # 复制所有文件到面板目录
            cp -rf "$TMP_DIR/repo/"* "$PANEL_DIR/"
            
            # 返回到原始目录
            cd "$CURRENT_DIR" || echo -e "${YELLOW}警告：无法返回原始目录${NC}"
            
            # 确保public目录存在
            if [ -d "$PANEL_DIR/public" ]; then
                echo -e "${GREEN}public目录复制成功${NC}"
            else
                echo -e "${RED}public目录复制失败${NC}"
                rm -rf "$TMP_DIR"
                return 1
            fi
            
            # 清理临时目录
            rm -rf "$TMP_DIR"
            
            return 0
        else
            echo -e "${RED}仓库中不包含public目录${NC}"
            # 返回到原始目录
            cd "$CURRENT_DIR" || echo -e "${YELLOW}警告：无法返回原始目录${NC}"
            rm -rf "$TMP_DIR"
            return 1
        fi
    else
        echo -e "${RED}克隆仓库失败${NC}"
        # 返回到原始目录
        cd "$CURRENT_DIR" || echo -e "${YELLOW}警告：无法返回原始目录${NC}"
        rm -rf "$TMP_DIR"
        return 1
    fi
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
            return 1
        fi
    fi
    
    # 检查面板目录是否存在
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}面板目录不存在: $PANEL_DIR${NC}"
        return 1
    fi
    
    # 检查package.json是否存在
    if [ ! -f "$PANEL_DIR/package.json" ]; then
        echo -e "${RED}找不到package.json文件: $PANEL_DIR/package.json${NC}"
        return 1
    fi
    
    # 保存当前目录
    CURRENT_DIR=$(pwd)
    
    # 切换到面板目录
    cd "$PANEL_DIR" || { echo -e "${RED}无法切换到面板目录${NC}"; return 1; }
    
    # 安装依赖
    npm install --production
    INSTALL_STATUS=$?
    
    # 返回到原始目录
    cd "$CURRENT_DIR" || echo -e "${YELLOW}警告：无法返回原始目录${NC}"
    
    if [ $INSTALL_STATUS -ne 0 ]; then
        echo -e "${RED}依赖安装失败${NC}"
        return 1
    fi
    
    echo -e "${GREEN}依赖安装完成${NC}"
    return 0
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

# 下载并启动服务
download_and_start() {
    echo -e "${YELLOW}下载并安装泰拉瑞亚服务器管理面板...${NC}"
    
    # 选择下载源
    select_source
    
    # 创建必要目录
    create_directories
    
    # 询问是否修改端口
    read -p "是否修改默认端口(10788)? [y/N]: " change_port_option
    if [[ "$change_port_option" =~ ^[Yy]$ ]]; then
        change_port
    fi
    
    # 下载面板文件
    download_panel
    
    # 安装依赖
    install_dependencies
    
    # 创建启动脚本
    create_start_script
    
    # 启动服务
    start_service
}

# 启动服务
start_service() {
    echo -e "${YELLOW}启动泰拉瑞亚服务器管理面板...${NC}"
    
    # 检查服务是否已经运行
    if [ -f "$BASE_DIR/panel.pid" ]; then
        pid=$(cat "$BASE_DIR/panel.pid")
        if ps -p $pid > /dev/null; then
            echo -e "${RED}服务已经在运行中，PID: $pid${NC}"
            return 1
        else
            rm "$BASE_DIR/panel.pid"
        fi
    fi
    
    # 检查面板目录是否存在
    if [ ! -d "$PANEL_DIR" ]; then
        echo -e "${RED}面板目录不存在: $PANEL_DIR${NC}"
        return 1
    fi
    
    # 保存当前目录
    CURRENT_DIR=$(pwd)
    
    # 切换到面板目录
    cd "$PANEL_DIR" || { echo -e "${RED}无法切换到面板目录${NC}"; return 1; }
    
    # 启动服务
    PORT=$PORT node server.js > "$LOG_FILE" 2>&1 &
    local server_pid=$!
    echo $server_pid > "$BASE_DIR/panel.pid"
    
    # 返回到原始目录
    cd "$CURRENT_DIR" || echo -e "${YELLOW}警告：无法返回原始目录${NC}"
    
    echo -e "${GREEN}服务已启动，PID: $server_pid，端口: $PORT${NC}"
    echo -e "${GREEN}请访问 http://localhost:$PORT 或 http://服务器IP:$PORT 访问管理面板${NC}"
}

# 停止服务
stop_service() {
    echo -e "${YELLOW}停止泰拉瑞亚服务器管理面板...${NC}"
    
    if [ -f "$BASE_DIR/panel.pid" ]; then
        pid=$(cat "$BASE_DIR/panel.pid")
        if ps -p $pid > /dev/null; then
            kill $pid
            echo -e "${GREEN}服务已停止，PID: $pid${NC}"
        else
            echo -e "${RED}服务未运行，但存在PID文件，正在清理...${NC}"
        fi
        rm "$BASE_DIR/panel.pid"
    else
        echo -e "${RED}找不到PID文件，服务可能未运行${NC}"
        # 尝试查找并杀死可能的Node.js进程
        pids=$(ps -ef | grep "node server.js" | grep -v grep | awk '{print $2}')
        if [ -n "$pids" ]; then
            echo -e "${YELLOW}找到可能的服务进程，尝试停止...${NC}"
            for p in $pids; do
                kill $p
                echo -e "${GREEN}已停止进程 $p${NC}"
            done
        fi
    fi
}

# 重启服务
restart_service() {
    echo -e "${YELLOW}重启泰拉瑞亚服务器管理面板...${NC}"
    stop_service
    sleep 2
    start_service
}

# 更新管理平台
update_platform() {
    echo -e "${YELLOW}更新泰拉瑞亚服务器管理面板...${NC}"
    
    # 选择下载源
    select_source
    
    # 备份当前配置
    if [ -f "$PANEL_DIR/server.js" ]; then
        cp "$PANEL_DIR/server.js" "$PANEL_DIR/server.js.bak"
    fi
    
    # 下载最新版本
    echo -e "${YELLOW}从${REPO_URL}下载最新版本...${NC}"
    download_panel
    
    # 恢复配置
    if [ -f "$PANEL_DIR/server.js.bak" ]; then
        cp "$PANEL_DIR/server.js.bak" "$PANEL_DIR/server.js"
    fi
    
    echo -e "${GREEN}更新完成${NC}"
    
    # 询问是否重启服务
    read -p "是否立即重启服务？[y/N]: " restart_option
    if [[ "$restart_option" =~ ^[Yy]$ ]]; then
        restart_service
    fi
}

# 强制更新平台
force_update() {
    echo -e "${YELLOW}强制更新泰拉瑞亚服务器管理面板...${NC}"
    
    # 停止服务
    stop_service
    
    # 选择下载源
    select_source
    
    # 备份重要文件
    mkdir -p "$BASE_DIR/backup"
    if [ -f "$PANEL_DIR/server.js" ]; then
        cp "$PANEL_DIR/server.js" "$BASE_DIR/backup/"
    fi
    
    # 清理当前文件
    rm -rf "$PANEL_DIR"/*
    
    # 下载最新版本
    echo -e "${YELLOW}从${REPO_URL}下载最新版本...${NC}"
    download_panel
    
    # 恢复配置
    if [ -f "$BASE_DIR/backup/server.js" ]; then
        cp "$BASE_DIR/backup/server.js" "$PANEL_DIR/"
    fi
    
    echo -e "${GREEN}强制更新完成${NC}"
    
    # 询问是否启动服务
    read -p "是否立即启动服务？[y/N]: " start_option
    if [[ "$start_option" =~ ^[Yy]$ ]]; then
        start_service
    fi
}

# 更新启动脚本
update_startup_script() {
    echo -e "${YELLOW}检查启动脚本更新...${NC}"
    
    # 选择下载源
    echo -e "${BLUE}请选择脚本下载源:${NC}"
    echo -e "1) GitHub (国际)"
    echo -e "2) Gitee (中国大陆)"
    echo -e "3) 自动选择 (推荐)"
    
    read -p "请输入选项 [1-3，默认3]: " source_option
    
    SCRIPT_URL=""
    case $source_option in
        1)
            SCRIPT_URL=$GITHUB_SCRIPT_URL
            echo -e "${GREEN}已选择 GitHub 源${NC}"
            ;;
        2)
            SCRIPT_URL=$GITEE_SCRIPT_URL
            echo -e "${GREEN}已选择 Gitee 源${NC}"
            ;;
        *)
            echo -e "${BLUE}自动选择最快的源...${NC}"
            # 测试GitHub连接速度
            start_time=$(date +%s%N)
            curl -s --connect-timeout 3 -o /dev/null $GITHUB_SCRIPT_URL
            github_status=$?
            end_time=$(date +%s%N)
            github_time=$((($end_time - $start_time)/1000000))
            
            # 测试Gitee连接速度
            start_time=$(date +%s%N)
            curl -s --connect-timeout 3 -o /dev/null $GITEE_SCRIPT_URL
            gitee_status=$?
            end_time=$(date +%s%N)
            gitee_time=$((($end_time - $start_time)/1000000))
            
            # 根据连接状态和速度选择源
            if [ $github_status -eq 0 ] && [ $gitee_status -eq 0 ]; then
                # 两个源都可用，选择更快的
                if [ $github_time -lt $gitee_time ]; then
                    SCRIPT_URL=$GITHUB_SCRIPT_URL
                    echo -e "${GREEN}已自动选择 GitHub 源 (响应时间: ${github_time}ms)${NC}"
                else
                    SCRIPT_URL=$GITEE_SCRIPT_URL
                    echo -e "${GREEN}已自动选择 Gitee 源 (响应时间: ${gitee_time}ms)${NC}"
                fi
            elif [ $github_status -eq 0 ]; then
                # 只有GitHub可用
                SCRIPT_URL=$GITHUB_SCRIPT_URL
                echo -e "${GREEN}已自动选择 GitHub 源${NC}"
            elif [ $gitee_status -eq 0 ]; then
                # 只有Gitee可用
                SCRIPT_URL=$GITEE_SCRIPT_URL
                echo -e "${GREEN}已自动选择 Gitee 源${NC}"
            else
                # 两个源都不可用，默认使用GitHub
                SCRIPT_URL=$GITHUB_SCRIPT_URL
                echo -e "${YELLOW}两个源都不可用，默认使用 GitHub 源${NC}"
            fi
            ;;
    esac
    
    # 下载脚本到临时文件
    echo -e "${BLUE}下载最新脚本...${NC}"
    TEMP_SCRIPT="/tmp/install.sh.$$"
    curl -s -L "$SCRIPT_URL" -o "$TEMP_SCRIPT"
    
    if [ $? -ne 0 ] || [ ! -s "$TEMP_SCRIPT" ]; then
        echo -e "${RED}下载脚本失败${NC}"
        rm -f "$TEMP_SCRIPT"
        return 1
    fi
    
    # 检查远程版本号
    REMOTE_VERSION=$(grep "^VERSION=" "$TEMP_SCRIPT" | cut -d'"' -f2)
    if [ -z "$REMOTE_VERSION" ]; then
        echo -e "${RED}无法确定远程脚本版本${NC}"
        rm -f "$TEMP_SCRIPT"
        return 1
    fi
    
    echo -e "${BLUE}当前版本: ${VERSION}${NC}"
    echo -e "${BLUE}远程版本: ${REMOTE_VERSION}${NC}"
    
    # 比较版本号
    if [ "$VERSION" = "$REMOTE_VERSION" ]; then
        # 版本号相同，检查文件内容是否有变化
        echo -e "${BLUE}版本号相同，检查文件内容是否有更新...${NC}"
        
        # 创建临时文件存储当前脚本（去除版本号行）
        CURRENT_CONTENT="/tmp/current_content.$$"
        REMOTE_CONTENT="/tmp/remote_content.$$"
        
        # 提取脚本内容（排除版本号行）
        grep -v "^VERSION=" "$0" > "$CURRENT_CONTENT"
        grep -v "^VERSION=" "$TEMP_SCRIPT" > "$REMOTE_CONTENT"
        
        # 比较文件内容
        if diff -q "$CURRENT_CONTENT" "$REMOTE_CONTENT" &>/dev/null; then
            echo -e "${GREEN}脚本内容无变化，已是最新版本${NC}"
            # 清理临时文件
            rm -f "$TEMP_SCRIPT" "$CURRENT_CONTENT" "$REMOTE_CONTENT"
            return 0
        else
            echo -e "${YELLOW}检测到脚本内容有更新${NC}"
            # 计算新版本号
            IFS='.' read -r -a version_parts <<< "$VERSION"
            patch_version=$((${version_parts[2]} + 1))
            NEW_VERSION="${version_parts[0]}.${version_parts[1]}.$patch_version"
            
            # 更新临时脚本中的版本号
            sed -i "s/^VERSION=.*$/VERSION=\"$NEW_VERSION\"  # 增加版本号/" "$TEMP_SCRIPT"
            
            echo -e "${BLUE}更新后版本: ${NEW_VERSION}${NC}"
        fi
        
        # 清理临时文件
        rm -f "$CURRENT_CONTENT" "$REMOTE_CONTENT"
    else
        # 远程版本号不同，直接使用远程版本号
        NEW_VERSION=$REMOTE_VERSION
    fi
    
    # 询问是否更新
    read -p "是否更新脚本？[Y/n]: " update_option
    if [[ ! "$update_option" =~ ^[Nn]$ ]]; then
        # 备份当前脚本
        BACKUP_SCRIPT="$BASE_DIR/install.sh.bak"
        cp "$0" "$BACKUP_SCRIPT"
        
        # 替换当前脚本
        cp "$TEMP_SCRIPT" "$0"
        chmod +x "$0"
        
        echo -e "${GREEN}脚本已更新到版本 ${NEW_VERSION}${NC}"
        echo -e "${BLUE}旧版本已备份到 ${BACKUP_SCRIPT}${NC}"
        
        # 询问是否重新执行脚本
        read -p "是否立即重新执行脚本？[Y/n]: " restart_option
        if [[ ! "$restart_option" =~ ^[Nn]$ ]]; then
            exec "$0"
            exit 0
        fi
    else
        echo -e "${YELLOW}已取消更新${NC}"
    fi
    
    # 清理临时文件
    rm -f "$TEMP_SCRIPT"
}

# 设置虚拟内存
setup_swap() {
    echo -e "${YELLOW}设置虚拟内存...${NC}"
    
    # 检查是否已经有swap
    if free | grep -q "Swap"; then
        swap_total=$(free | grep "Swap" | awk '{print $2}')
        if [ "$swap_total" -gt 0 ]; then
            echo -e "${YELLOW}系统已有$(($swap_total/1024))MB虚拟内存${NC}"
            read -p "是否重新设置？[y/N]: " reset_swap
            if [[ ! "$reset_swap" =~ ^[Yy]$ ]]; then
                return 0
            fi
            
            # 关闭已有的swap
            echo -e "${YELLOW}关闭已有的虚拟内存...${NC}"
            swapoff -a
        fi
    fi
    
    # 询问swap大小
    read -p "请输入要设置的虚拟内存大小(MB)，建议为物理内存的1-2倍: " swap_size
    
    # 验证输入
    if ! [[ "$swap_size" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}输入错误，请输入数字${NC}"
        return 1
    fi
    
    # 创建swap文件
    echo -e "${YELLOW}创建${swap_size}MB的虚拟内存文件...${NC}"
    dd if=/dev/zero of=/swapfile bs=1M count=$swap_size
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # 设置开机自动挂载
    if ! grep -q "/swapfile" /etc/fstab; then
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi
    
    echo -e "${GREEN}虚拟内存设置完成，大小: ${swap_size}MB${NC}"
}

# 主函数
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            0)
                download_and_start
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            1)
                start_service
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            2)
                stop_service
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            3)
                restart_service
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            4)
                update_platform
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            5)
                force_update
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            6)
                change_port
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            7)
                update_startup_script
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            8)
                setup_swap
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            9)
                echo -e "${GREEN}感谢使用泰拉瑞亚服务器管理平台，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                sleep 2
                ;;
        esac
    done
}

# 执行主函数
main 