#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# 设置端口
PORT=${PORT:-10788}

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未安装Node.js，请先安装Node.js${NC}"
    exit 1
fi

# 检查npm是否安装
if ! command -v npm &> /dev/null; then
    echo -e "${RED}错误: 未安装npm，请先安装npm${NC}"
    exit 1
fi

# 检查依赖是否已安装
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}安装依赖...${NC}"
    npm install
fi

# 检查public目录是否存在
if [ -d "public" ]; then
    echo -e "${GREEN}找到UI界面，将使用UI界面${NC}"
else
    echo -e "${RED}错误: 未找到UI界面文件，请确保public目录存在${NC}"
    exit 1
fi

# 启动服务器
echo -e "${GREEN}启动泰拉瑞亚服务器管理面板，端口: ${PORT}${NC}"
PORT=$PORT node server.js

# 如果服务器异常退出，输出错误信息
if [ $? -ne 0 ]; then
    echo -e "${RED}服务器异常退出${NC}"
    exit 1
fi 