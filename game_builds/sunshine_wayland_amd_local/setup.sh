#!/bin/bash

echo "Setting up init"

echo "setting correct video card"
#sudo rm /dev/dri/renderD128
#sudo ln -s /dev/dri/renderD129 /dev/dri/renderD128
sudo chmod 777 -R /dev/dri

echo "initting udevd"
XDG_RUNTIME_DIR=/tmp sudo /lib/systemd/systemd-udevd &
sleep 5

echo "starting dbus"
XDG_RUNTIME_DIR=/tmp sudo dbus-daemon --system &
XDG_RUNTIME_DIR=/run/user/1000 dbus-daemon --session &
sleep 5

echo "starting sway"
XDG_RUNTIME_DIR=/run/user/1000 sway --unsupported-gpu &
sleep 5

echo "starting pipewire"
XDG_RUNTIME_DIR=/run/user/1000 pipewire &
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 pipewire-pulse &
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 wireplumber &

sleep 5
pw-loopback -m '[ FL FR]' --capture-props='media.class=Audio/Sink node.name=sink-sunshine-stereo' &

# echo "starting sunshine"
sleep 5
XDG_RUNTIME_DIR=/run/user/1000 sunshine /home/lizard/.config/sunshine/sunshine.conf &

# echo "start pod healthcheck"
sleep 5
python3 -m http.server 50000

# echo "starting game"
#sleep 5
#XDG_RUNTIME_DIR=/run/user/1000 /usr/games/AstroMenace