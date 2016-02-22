#!/bin/bash

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -p|--proxy)
    PROXY="$2"
    shift # past argument
    ;;
    -h|--help)
    HELP="1"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [[ "$HELP" == "1" ]]; then
  echo "./install-release.sh [-p proxy]"
  echo "To download through a proxy server, use -p socks5://127.0.0.1:1080 or -p http://127.0.0.1:3128 etc"
  exit
fi
VER="v1.7"
VDIS="64"
unzip "/tmp/v2ray/v2ray.zip" -d "/tmp/v2ray/"

# Create folder for V2Ray log.
mkdir -p /var/log/v2ray

# Stop v2ray daemon if necessary.
SYSTEMCTL_CMD=$(command -v systemctl)
SERVICE_CMD=$(command -v service)
ISRUN_CMD=$(ps x | grep -c v2ray)

if [ ${ISRUN_CMD} -eq 2 ]; then
  if [ -n "${SYSTEMCTL_CMD}" ]; then
    if [ -f "/lib/systemd/system/v2ray.service" ]; then
      systemctl stop v2ray
    fi
  elif [ -n "${SERVICE_CMD}" ]; then
    if [ -f "/etc/init.d/v2ray" ]; then
      service v2ray stop
    fi
  fi
fi

# Install V2Ray binary to /usr/bin/v2ray
mkdir -p /usr/bin/v2ray
cp "/tmp/v2ray/v2ray-${VER}-linux-${VDIS}/v2ray" "/usr/bin/v2ray/v2ray"
chmod +x "/usr/bin/v2ray/v2ray"

# Install V2Ray server config to /etc/v2ray
mkdir -p /etc/v2ray
if [ ! -f "/etc/v2ray/config.json" ]; then
  cp "/tmp/v2ray/v2ray-${VER}-linux-${VDIS}/vpoint_vmess_freedom.json" "/etc/v2ray/config.json"

  let PORT=$RANDOM+10000
  sed -i "s/38291/${PORT}/g" "/etc/v2ray/config.json"

  UUID=$(cat /proc/sys/kernel/random/uuid)
  sed -i "s/8833948b-5861-4a0f-a1d6-83c5606881ff/${UUID}/g" "/etc/v2ray/config.json"

  echo "PORT:${PORT}"
  echo "UUID:${UUID}"
fi

if [ -n "${SYSTEMCTL_CMD}" ]; then
  if [ ! -f "/lib/systemd/system/v2ray.service" ]; then
    cp "/tmp/v2ray/v2ray-${VER}-linux-${VDIS}/systemd/v2ray.service" "/lib/systemd/system/"
    systemctl enable v2ray
  else
    if [ ${ISRUN_CMD} -eq 2 ]; then
      systemctl start v2ray
    fi
  fi
elif [ -n "${SERVICE_CMD}" ]; then # Configure SysV if necessary.
  if [ ! -f "/etc/init.d/v2ray" ]; then
    cp "/tmp/v2ray/v2ray-${VER}-linux-${VDIS}/systemv/v2ray" "/etc/init.d/v2ray"
    chmod +x "/etc/init.d/v2ray"
    update-rc.d v2ray defaults
  else
    if [ ${ISRUN_CMD} -eq 2 ]; then
      service v2ray start
    fi
  fi
fi
