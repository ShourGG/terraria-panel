#!/bin/bash

# 泰拉瑞亚服务器管理面板 - 自动安装脚本
# 此脚本会自动选择最快的源下载安装程序并执行

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m' # 恢复默认颜色

echo -e "${BLUE}=== 泰拉瑞亚服务器管理面板 - 自动安装程序 ===${NC}"
echo -e "${BLUE}正在检测最佳下载源...${NC}"

# 定义下载源
GITHUB_URL="https://raw.githubusercontent.com/ShourGG/terraria-panel/main"
GITEE_URL="https://gitee.com/cd-writer/terraria-panel/raw/main"

# 测试GitHub连接速度
start_time=$(date +%s)
curl -s --connect-timeout 3 -o /dev/null $GITHUB_URL/README.md
github_status=$?
end_time=$(date +%s)
github_time=$(($end_time - $start_time))

# 测试Gitee连接速度
start_time=$(date +%s)
curl -s --connect-timeout 3 -o /dev/null $GITEE_URL/README.md
gitee_status=$?
end_time=$(date +%s)
gitee_time=$(($end_time - $start_time))

# 根据连接状态和速度选择源
if [ $github_status -eq 0 ] && [ $gitee_status -eq 0 ]; then
    # 两个源都可用，选择更快的
    if [ $github_time -lt $gitee_time ]; then
        INSTALL_URL=$GITHUB_URL
        echo -e "${GREEN}已选择 GitHub 源 (响应时间: ${github_time}s)${NC}"
    else
        INSTALL_URL=$GITEE_URL
        echo -e "${GREEN}已选择 Gitee 源 (响应时间: ${gitee_time}s)${NC}"
    fi
elif [ $github_status -eq 0 ]; then
    # 只有GitHub可用
    INSTALL_URL=$GITHUB_URL
    echo -e "${GREEN}已选择 GitHub 源${NC}"
elif [ $gitee_status -eq 0 ]; then
    # 只有Gitee可用
    INSTALL_URL=$GITEE_URL
    echo -e "${GREEN}已选择 Gitee 源${NC}"
else
    # 两个源都不可用
    echo -e "${RED}无法连接到下载源，请检查网络连接${NC}"
    exit 1
fi

# 下载安装脚本
echo -e "${BLUE}正在下载安装脚本...${NC}"
curl -L --connect-timeout 5 "$INSTALL_URL/install.sh" -o install.sh

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo -e "${RED}下载安装脚本失败，尝试使用备用源...${NC}"
    
    # 如果当前是GitHub源，则尝试Gitee源
    if [ "$INSTALL_URL" = "$GITHUB_URL" ]; then
        curl -L --connect-timeout 5 "$GITEE_URL/install.sh" -o install.sh
    else
        curl -L --connect-timeout 5 "$GITHUB_URL/install.sh" -o install.sh
    fi
    
    # 再次检查下载是否成功
    if [ $? -ne 0 ]; then
        echo -e "${RED}无法下载安装脚本，请检查网络连接或手动下载${NC}"
        exit 1
    fi
fi

# 设置执行权限
chmod +x install.sh

# 执行安装脚本
echo -e "${GREEN}下载完成，开始安装...${NC}"
./install.sh

# 清理
rm -f auto_install.sh 