#!/bin/bash

echo "Setting up init"

echo "setting correct video card"
sudo rm /dev/dri/renderD128
sudo ln -s /dev/dri/renderD129 /dev/dri/renderD128
sudo chmod 777 -R /dev/dri

echo "initting udevd"
XDG_RUNTIME_DIR=/tmp sudo /lib/systemd/systemd-udevd &
sleep 5

echo "starting dbus"
XDG_RUNTIME_DIR=/tmp sudo dbus-daemon --system &
XDG_RUNTIME_DIR=/run/user/1000 dbus-daemon --session &
#sleep 5

sleep infinity

echo "starting xorg"
#sudo mkdir -p /tmp/.X11-unix
#sudo chmod 1777 /tmp/.X11-unix
#sudo XDG_RUNTIME_DIR=/tmp/.X11-unix Xorg -ac -noreset +extension GLX +extension RANDR +extension RENDER vt1 "${DISPLAY}"

DISPLAY_NUMBER=${DISPLAY:1}
DISPLAY_FILE=/tmp/.X11-unix/X${DISPLAY_NUMBER}
if [ -S "${DISPLAY_FILE}" ]; then
  gow_log "Removing ${DISPLAY_FILE} before starting"
  rm -f "/tmp/.X${DISPLAY_NUMBER}-lock"
  rm "${DISPLAY_FILE}"
fi

_kill_procs() {
  kill -TERM "$xorg"
  wait "$xorg"
  kill -TERM "$jwm"
  wait "$jwm"
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

# Start Xorg
echo "Starting Xorg (${DISPLAY}, log level ${XORG_VERBOSE})"
sudo XDG_RUNTIME_DIR=/tmp/.X11-unix Xorg -logverbose "${XORG_VERBOSE}" -ac -noreset +extension GLX +extension RANDR +extension RENDER vt1 "${DISPLAY}" &
xorg=$!

jwm &
jwm=$!

# Setting up resolution
RESOLUTION=${RESOLUTION:-1920x1080}
REFRESH_RATE=${REFRESH_RATE:-60}

# wait for the X server to finish starting
for i in {0..120}; do
    if  xdpyinfo >/dev/null 2>&1; then
        break
    fi

    sleep 1s
done

output_log=$'Detected outputs:\n'
for out in $(xrandr --current | awk '/ (dis)?connected/ { print $1 }'); do
    output_log+="    - $out"
    output_log+=$'\n'
done
echo "$output_log"

CURRENT_OUTPUT=${CURRENT_OUTPUT:-$(xrandr --current | awk '/ connected/ { print $1; }')}
echo "Setting ${CURRENT_OUTPUT} output to: ${RESOLUTION}@${REFRESH_RATE}"

# First try to use an already set resolution, if available
if ! xrandr --output "${CURRENT_OUTPUT}" --mode "${RESOLUTION}" --rate "${REFRESH_RATE}"; then
  FORCE_RESOLUTION=${FORCE_RESOLUTION:-false}
  echo "${RESOLUTION} is not detected, FORCE_RESOLUTION=${FORCE_RESOLUTION}"

  # this line disables the check for the whole if block
  # shellcheck disable=SC2086
  if $FORCE_RESOLUTION; then
    WIDTH_HEIGHT=("${RESOLUTION//x/ }")
    MODELINE=$(cvt ${WIDTH_HEIGHT[0]} ${WIDTH_HEIGHT[1]} ${REFRESH_RATE} | awk 'FNR==2{print substr($0, index($0,$3))}')
    xrandr --newmode "${RESOLUTION}_${REFRESH_RATE}.00" ${MODELINE}
    xrandr --addmode ${CURRENT_OUTPUT} "${RESOLUTION}_${REFRESH_RATE}.00"
    xrandr --output ${CURRENT_OUTPUT} --mode "${RESOLUTION}_${REFRESH_RATE}.00" --rate ${REFRESH_RATE} --primary
  fi
fi

DISABLE_OUTPUTS=${DISABLE_OUTPUTS:-}
for i in ${DISABLE_OUTPUTS//,/ }; do
    xrandr --output "$i" --off
done

wait $xorg
wait $jwm
sleep 5

echo "starting pipewire"
XDG_RUNTIME_DIR=/run/user/1000 pipewire &
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 pipewire-pulse &
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 wireplumber &

sleep 5
pw-loopback -m '[ FL FR]' --capture-props='media.class=Audio/Sink node.name=sink-sunshine-stereo' &

echo "starting sunshine"
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 sunshine /home/lizard/.config/sunshine/sunshine.conf &

echo "start pod healthcheck"
sleep 5
python3 -m http.server 50000 &

# echo "starting game"
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 /usr/games/AstroMenace