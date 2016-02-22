FROM vistateam/base_system

MAINTAINER VistaTeam_AppleBugs <2555085@qq.com>

ADD v2ray_install.sh /tmp/v2ray_install.sh
RUN mkdir -p /tmp/v2ray
ADD v2ray-linux-64.zip /tmp/v2ray/v2ray.zip
ADD supervisor_v2ray.conf /etc/supervisor.conf.d/supervisor_v2ray.conf

RUN /tmp/v2ray_install.sh
RUN mv /etc/v2ray/config.json /etc/v2ray/config.json.bak
ADD config.json /etc/v2ray/config.json
ADD init.sh /init.sh

EXPOSE 17173
EXPOSE 30001

entrypoint ["/init.sh", "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
