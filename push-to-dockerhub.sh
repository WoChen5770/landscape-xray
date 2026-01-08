#!/bin/bash

# Docker Hub推送脚本
# 用于将landscape-xray镜像推送到Docker Hub

echo "开始推送 Landscape Xray 镜像到 Docker Hub..."

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装或不在 PATH 中"
    exit 1
fi

# 设置变量
LOCAL_IMAGE="landscape-xray:latest"
DOCKERHUB_REPO="jaycq/landscape-xray"
TAG="latest"

# 检查本地镜像是否存在
if ! docker image inspect "$LOCAL_IMAGE" &> /dev/null; then
    echo "错误: 本地镜像 $LOCAL_IMAGE 不存在，请先构建镜像"
    echo "运行: docker build -t landscape-xray:latest ."
    exit 1
fi

# 登录Docker Hub（如果需要）
if ! docker login; then
    echo "警告: Docker Hub登录失败或已跳过"
    echo "如果之前已经登录过，可以继续"
fi

# 标记镜像
echo "标记镜像: $LOCAL_IMAGE -> $DOCKERHUB_REPO:$TAG"
docker tag "$LOCAL_IMAGE" "$DOCKERHUB_REPO:$TAG"

# 推送镜像
echo "推送镜像到 Docker Hub: $DOCKERHUB_REPO:$TAG"
docker push "$DOCKERHUB_REPO:$TAG"

if [ $? -eq 0 ]; then
    echo "✅ 镜像推送成功!"
    echo ""
    echo "镜像地址: https://hub.docker.com/r/jaycq/landscape-xray"
    echo ""
    echo "使用命令:"
    echo "  docker pull jaycq/landscape-xray:latest"
    echo "  docker run -d --name landscape-xray -p 1080:1080 jaycq/landscape-xray:latest"
else
    echo "❌ 镜像推送失败"
    exit 1
fi