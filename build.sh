#!/bin/bash

# Xray Docker 镜像构建脚本

echo "开始构建 Xray Docker 镜像..."

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装或不在 PATH 中"
    exit 1
fi

# 设置变量
IMAGE_NAME="landscape-xray"
TAG="latest"
TIMEZONE="Asia/Shanghai"

# 构建镜像
echo "构建镜像: ${IMAGE_NAME}:${TAG}"
docker build \
    --build-arg TZ=${TIMEZONE} \
    -t ${IMAGE_NAME}:${TAG} .

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功!"
    echo ""
    echo "运行命令:"
    echo "  docker run -d --name xray -p 1080:1080 -v \$(pwd)/config:/usr/local/etc/xray -v \$(pwd)/logs:/var/log/xray ${IMAGE_NAME}:${TAG}"
else
    echo "❌ 镜像构建失败"
    exit 1
fi