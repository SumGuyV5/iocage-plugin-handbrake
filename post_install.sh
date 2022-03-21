#!/bin/sh -x
IP_ADDRESS=$(ifconfig | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}')

APP_NAME="HandBrake"

sed -i.bak "s/<application type=\"normal\">/<application type=\"normal\" title=\"${APP_NAME}\">/" /usr/local/etc/xdg/openbox/rc.xml
sed -i.bak "/<application type=\"normal\" title=\"${APP_NAME}\">/a \\
    <layer>below</layer>
" /usr/local/etc/xdg/openbox/rc.xml

ln -s /usr/local/bin/python3.8 /usr/local/bin/python

cp /usr/local/libexec/novnc/vnc_lite.html /usr/local/libexec/novnc/index.html

sed -i.bak "s|<title>noVNC</title>|<title>${APP_NAME}</title>|" /usr/local/libexec/novnc/index.html

openssl req -new -x509 -days 365 -nodes -out self.pem -keyout /usr/local/libexec/novnc/utils/websockify/self.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=Global Security/OU=IT Department/CN=vnc"

VNC_PASS=$(openssl rand -base64 20 | md5 | head -c20)
USER_PASS=$(openssl rand -base64 20 | md5 | head -c6)

sysrc websockify_enable=YES
service websockify start

sysrc x11vnc_enable=YES
service x11vnc start

echo -e "Handbrake now installed.\n" > /root/PLUGIN_INFO
echo -e "\nGo to http://$IP_ADDRESS:6080\n" >> /root/PLUGIN_INFO