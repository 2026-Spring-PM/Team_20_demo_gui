#!/bin/bash
# Docker 이미지를 빌드하고 (선택적으로) Docker Hub에 푸시하는 스크립트
# 사용법: ./docker_build.sh [--push]

set -e  # 에러 발생 시 즉시 종료

DOCKERHUB_USER="mono1ka"    
TEAM_NUMBER="team_20"      
VERSION="0.1.0"

IMAGE_NAME="${DOCKERHUB_USER}/${TEAM_NUMBER}_project:${VERSION}"

echo "================================================"
echo "Building Docker image: ${IMAGE_NAME}"
echo "================================================"

# Dockerfile이 있는 디렉토리로 이동
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "${SCRIPT_DIR}"

# linux/amd64 플랫폼으로 빌드 (M1/M2 Mac에서도 호환되도록)
docker build --platform linux/amd64 -t "${IMAGE_NAME}" .

echo ""
echo "✅ Build complete: ${IMAGE_NAME}"
echo ""

# --push 옵션이 있으면 Docker Hub에 업로드
if [[ "$1" == "--push" ]]; then
    echo "Pushing to Docker Hub..."
    docker push "${IMAGE_NAME}"
    echo "✅ Pushed: ${IMAGE_NAME}"
fi
