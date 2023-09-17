# syntax=docker/dockerfile:1.4
# artifacts: true
# platforms: linux/amd64,linux/arm64/v8
# platforms_pr: linux/amd64
# no-cache-filters: sunshine-base,artifacts,sunshine


FROM lizardbyte/sunshine:8ff2022-ubuntu-22.04
ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update && apt-get install -y astromenace x11-apps mesa-utils libxrender1 libwayland-server0 libvulkan1 libxrender-dev libdrm-amdgpu1 \
    libva-drm2 libva-x11-2 va-driver-all libgbm1 libgles2-mesa libegl1 libgl1-mesa-dri libvulkan1 libvdpau1 libnuma1 \
    libavahi-client3 libgles2-mesa mesa-vulkan-drivers mesa-vdpau-drivers libwayland-egl1 libgles2-mesa-dev mesa-utils-extra libappindicator3-1 libopus0 libmfx1 vainfo apt-file libboost-chrono1.74.0 udev \
    libcap2-bin libxres-dev libxres1 libsdl2-2.0-0 sway xwayland libgles2 pciutils kmod libwayland-egl1 mesa-va-drivers \
    pipewire pipewire-pulse wget sudo make pulseaudio pipewire-audio-client-libraries libspa-0.2-dev libpipewire-0.3-dev gstreamer1.0-pipewire dbus-x11 bash-completion && apt-file update

RUN  mkdir -p /src && \
    cd /src && \
    wget http://repo.steampowered.com/steam/archive/precise/steam_latest.tar.gz && \
    tar xzvf steam_latest.tar.gz && \
    cd /src/steam-launcher && \
    make install && echo "========== Setup sudoers ==========" && \
    echo "lizard    ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "========== Install Steam =========="

RUN echo 'root:123' | chpasswd
RUN setcap cap_sys_admin+p $(readlink -f $(which sunshine))
RUN mkdir -p /run/dbus
RUN mkdir -p /dev/snd
RUN mkdir -p /run/user/1000 && chown lizard /run/user/1000

RUN apt-get install -y wireplumber alsa-utils curl gnupg2 libcudart11.0 nvidia-cuda-dev nvidia-profiler

RUN  distribution=$(. /etc/os-release;echo $ID$VERSION_ID) &&\
    echo "$distribution" &&\
    curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | apt-key add - &&\
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | tee /etc/apt/sources.list.d/libnvidia-container.list &&\
    apt-get update && apt-get install -y nvidia-utils-535-server nvidia-container-toolkit

RUN apt-get install -y libnvidia-fbc1-535 libdrm-nouveau2 libdrm2 xserver-xorg-core xcvt xfonts-base x11-apps \
    x11-session-utils x11-utils x11-xfs-utils \
    x11-xserver-utils xauth x11-common \
    xz-utils unzip avahi-utils dbus \
    mesa-utils mesa-utils-extra \
    vulkan-tools \
    libgl1-mesa-glx libgl1-mesa-dri libglu1-mesa \
    xserver-xorg-video-all \
    xserver-xorg-input-libinput \
    jwm libxft2 libxext6 breeze-cursor-theme

USER lizard

ENV DISABLE_RTKIT=y
ENV PIPEWIRE_RUNTIME_DIR=/run/user/1000
ENV PULSE_RUNTIME_DIR=/run/user/1000
#ENV XDG_RUNTIME_DIR=/run/user/1000
ENV XDG_SESSION_TYPE=x11
ENV DISPLAY=:1
#ENV NVIDIA_VISIBLE_DEVICES all
#ENV NVIDIA_DRIVER_CAPABILITIES all

COPY setup.sh $HOME/setup.sh
COPY sunshine/ /home/lizard/.config/sunshine

ENTRYPOINT /home/lizard/setup.sh