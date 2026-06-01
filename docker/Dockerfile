# Base image provided by the course (GCC 13 included)
FROM chwoong/team_00_project:0.1.0

# 개발자 정보
LABEL maintainer="Team_20"
LABEL description="Farm Village Simulator - Dragonshire (SFML, browser-playable via VNC)"

# Non-interactive mode (apt 설치 시 입력 프롬프트 방지)
ENV DEBIAN_FRONTEND=noninteractive

# 라이브러리 설치
# --- SFML / GUI 런타임 ---
# - libsfml-dev: SFML 개발 헤더 + 라이브러리
# - libx11-dev, libxrandr-dev, libxcursor-dev, libxi-dev: X11 GUI 지원
# - libgl1-mesa-dev: OpenGL 헤더/라이브러리
# - libgl1-mesa-dri: 소프트웨어 OpenGL 렌더링 (Xvfb 가상 디스플레이용, GPU 불필요)
# - libfreetype6-dev: 폰트 렌더링
# - libudev-dev: 입력 장치
# - libopenal-dev, libflac-dev, libvorbis-dev: 오디오 (SFML Audio 모듈용)
# - cmake: 빌드 시스템
# - x11-apps: X11 동작 확인용 (xeyes 등)
# --- 헤드리스 디스플레이 + 브라우저 플레이 (VNC) ---
# - xvfb: 가상 X 디스플레이 (모니터 없이 GUI 실행)
# - x11vnc: 가상 디스플레이를 VNC로 노출
# - novnc + websockify: 브라우저에서 접속할 수 있는 웹 VNC 클라이언트
# - fluxbox: 게임 창에 키보드 포커스를 주기 위한 경량 윈도우 매니저
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsfml-dev \
    libx11-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libfreetype6-dev \
    libudev-dev \
    libopenal-dev \
    libflac-dev \
    libvorbis-dev \
    cmake \
    x11-apps \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리
WORKDIR /workspace

# 브라우저(noVNC) 접속 포트 (문서용; 실제 매핑은 run.sh 의 -p 로 수행)
EXPOSE 6080

# 컨테이너 실행 시 기본 셸
CMD ["/bin/bash"]
