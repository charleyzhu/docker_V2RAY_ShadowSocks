#!/bin/bash
V2RAY_USERID=${V2RAY_USERID:-1ad52bdc-16d1-41a5-811d-f5c0c76d677b}
V2RAY_ALTERID=${V2RAY_ALTERID:-5589}
V2RAY_SS_PASS=${V2RAY_SS_PASS:-docker}

sed -i "s/1ad52bdc-16d1-41a5-811d-f5c0c76d677b/$V2RAY_USERID/g" /etc/v2ray/config.json
sed -i "s/5589/$V2RAY_ALTERID/g" /etc/v2ray/config.json
sed -i "s/docker/$V2RAY_SS_PASS/g" /etc/v2ray/config.json

exec "$@"
