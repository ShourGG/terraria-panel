#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# 设置端口
PORT=${PORT:-10788}
BASE_DIR=$(pwd)
LOG_FILE="$BASE_DIR/panel.log"

# 清屏函数
clear_screen() {
    clear
}

# 显示菜单
show_menu() {
    clear_screen
    echo -e "${BLUE}泰拉瑞亚服务器管理平台(Terraria Management Platform)${NC}"
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
    echo -e "${BLUE}[6]: 更新启动脚本(Update startup script)${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}[7]: 设置虚拟内存(Setup swap)${NC}"
    echo -e "${BLUE}[8]: 退出脚本(Exit script)${NC}"
    echo -e "${BLUE}————————————————————————————————————————————————————————————${NC}"
    echo -e "${YELLOW}请输入选择(Please enter your selection) [0-8]:${NC}"
}

# 下载并启动服务
download_and_start() {
    echo -e "${YELLOW}下载并安装泰拉瑞亚服务器管理面板...${NC}"
    
    # 检查是否已经安装
    if [ -f "server.js" ] && [ -d "dist" ]; then
        echo -e "${YELLOW}检测到已安装管理面板，是否重新安装？[y/N]${NC}"
        read -r reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}跳过安装，直接启动服务...${NC}"
            start_service
            return
        fi
    fi
    
    # 执行安装脚本
    if [ -f "install.sh" ]; then
        bash install.sh
    else
        echo -e "${RED}找不到安装脚本install.sh${NC}"
        echo -e "${YELLOW}尝试从GitHub下载安装脚本...${NC}"
        curl -s -L https://github.com/ShourGG/terraria-panel/raw/koi-ui/install.sh -o install.sh
        if [ $? -eq 0 ]; then
            chmod +x install.sh
            bash install.sh
        else
            echo -e "${RED}下载安装脚本失败${NC}"
            return 1
        fi
    fi
    
    # 安装完成后启动服务
    start_service
}

# 启动服务
start_service() {
    echo -e "${YELLOW}启动泰拉瑞亚服务器管理面板...${NC}"
    
    # 检查服务是否已经运行
    if [ -f "panel.pid" ]; then
        pid=$(cat panel.pid)
        if ps -p $pid > /dev/null; then
            echo -e "${RED}服务已经在运行中，PID: $pid${NC}"
            return 1
        else
            rm panel.pid
        fi
    fi
    
    # 启动服务
    if [ -f "start.sh" ]; then
        bash start.sh > $LOG_FILE 2>&1 &
        echo $! > panel.pid
        echo -e "${GREEN}服务已启动，PID: $(cat panel.pid)，端口: $PORT${NC}"
    else
        echo -e "${YELLOW}找不到启动脚本start.sh，尝试直接启动服务...${NC}"
        if [ -f "server.js" ]; then
            PORT=$PORT node server.js > $LOG_FILE 2>&1 &
            echo $! > panel.pid
            echo -e "${GREEN}服务已启动，PID: $(cat panel.pid)，端口: $PORT${NC}"
        else
            echo -e "${RED}找不到server.js，无法启动服务${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}请访问 http://localhost:$PORT 或 http://服务器IP:$PORT 访问管理面板${NC}"
}

# 停止服务
stop_service() {
    echo -e "${YELLOW}停止泰拉瑞亚服务器管理面板...${NC}"
    
    if [ -f "panel.pid" ]; then
        pid=$(cat panel.pid)
        if ps -p $pid > /dev/null; then
            kill $pid
            echo -e "${GREEN}服务已停止，PID: $pid${NC}"
        else
            echo -e "${RED}服务未运行，但存在PID文件，正在清理...${NC}"
        fi
        rm panel.pid
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
    
    # 备份当前配置
    if [ -f "server.js" ]; then
        cp server.js server.js.bak
    fi
    
    # 下载最新版本
    echo -e "${YELLOW}从GitHub下载最新版本...${NC}"
    curl -s -L https://github.com/ShourGG/terraria-panel/archive/refs/heads/koi-ui.zip -o terraria-panel.zip
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}下载失败，尝试从Gitee下载...${NC}"
        curl -s -L https://gitee.com/cd-writer/terraria-panel/repository/archive/koi-ui.zip -o terraria-panel.zip
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}更新失败，无法下载最新版本${NC}"
            return 1
        fi
    fi
    
    # 解压并更新文件
    echo -e "${YELLOW}解压文件并更新...${NC}"
    unzip -o terraria-panel.zip
    
    # 复制新文件
    cp -r terraria-panel-koi-ui/* .
    
    # 清理临时文件
    rm -rf terraria-panel.zip terraria-panel-koi-ui
    
    # 恢复配置
    if [ -f "server.js.bak" ]; then
        cp server.js.bak server.js
    fi
    
    echo -e "${GREEN}更新完成${NC}"
    
    # 询问是否重启服务
    echo -e "${YELLOW}是否立即重启服务？[y/N]${NC}"
    read -r restart
    if [[ $restart =~ ^[Yy]$ ]]; then
        restart_service
    fi
}

# 强制更新平台
force_update() {
    echo -e "${YELLOW}强制更新泰拉瑞亚服务器管理面板...${NC}"
    
    # 停止服务
    stop_service
    
    # 备份重要文件
    mkdir -p backup
    if [ -f "server.js" ]; then
        cp server.js backup/
    fi
    
    # 下载最新版本
    echo -e "${YELLOW}从GitHub下载最新版本...${NC}"
    curl -s -L https://github.com/ShourGG/terraria-panel/archive/refs/heads/koi-ui.zip -o terraria-panel.zip
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}下载失败，尝试从Gitee下载...${NC}"
        curl -s -L https://gitee.com/cd-writer/terraria-panel/repository/archive/koi-ui.zip -o terraria-panel.zip
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}更新失败，无法下载最新版本${NC}"
            return 1
        fi
    fi
    
    # 清理当前文件
    find . -maxdepth 1 -not -name "backup" -not -name "terraria-panel.zip" -not -name "." -not -name ".." -not -name "menu.sh" -exec rm -rf {} \;
    
    # 解压并更新文件
    echo -e "${YELLOW}解压文件并更新...${NC}"
    unzip -o terraria-panel.zip
    
    # 复制新文件
    cp -r terraria-panel-koi-ui/* .
    
    # 清理临时文件
    rm -rf terraria-panel.zip terraria-panel-koi-ui
    
    # 恢复配置
    if [ -f "backup/server.js" ]; then
        cp backup/server.js .
    fi
    
    echo -e "${GREEN}强制更新完成${NC}"
    
    # 询问是否启动服务
    echo -e "${YELLOW}是否立即启动服务？[y/N]${NC}"
    read -r start
    if [[ $start =~ ^[Yy]$ ]]; then
        start_service
    fi
}

# 更新启动脚本
update_startup_script() {
    echo -e "${YELLOW}更新启动脚本...${NC}"
    
    # 下载最新的启动脚本
    curl -s -L https://github.com/ShourGG/terraria-panel/raw/koi-ui/start.sh -o start.sh
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}下载失败，尝试从Gitee下载...${NC}"
        curl -s -L https://gitee.com/cd-writer/terraria-panel/raw/koi-ui/start.sh -o start.sh
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}更新启动脚本失败${NC}"
            return 1
        fi
    fi
    
    chmod +x start.sh
    echo -e "${GREEN}启动脚本更新完成${NC}"
}

# 设置虚拟内存
setup_swap() {
    echo -e "${YELLOW}设置虚拟内存...${NC}"
    
    # 检查是否已经有swap
    if free | grep -q "Swap"; then
        swap_total=$(free | grep "Swap" | awk '{print $2}')
        if [ "$swap_total" -gt 0 ]; then
            echo -e "${YELLOW}系统已有$(($swap_total/1024))MB虚拟内存${NC}"
            echo -e "${YELLOW}是否重新设置？[y/N]${NC}"
            read -r reset_swap
            if [[ ! $reset_swap =~ ^[Yy]$ ]]; then
                return 0
            fi
            
            # 关闭已有的swap
            echo -e "${YELLOW}关闭已有的虚拟内存...${NC}"
            swapoff -a
        fi
    fi
    
    # 询问swap大小
    echo -e "${YELLOW}请输入要设置的虚拟内存大小(MB)，建议为物理内存的1-2倍:${NC}"
    read -r swap_size
    
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
                update_startup_script
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            7)
                setup_swap
                echo -e "${YELLOW}按Enter键继续...${NC}"
                read
                ;;
            8)
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