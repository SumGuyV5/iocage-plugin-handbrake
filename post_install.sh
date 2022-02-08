#!/bin/sh -x
IP_ADDRESS=$(ifconfig | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}')

ln -s /usr/local/bin/python3.8 /usr/local/bin/python

ln -s /usr/local/libexec/novnc/vnc_lite.html /usr/local/libexec/novnc/index.html

#ln -s /usr/local/libexec/novnc/utils/websockify/websockify.py /usr/local/bin/websockify

openssl req -new -x509 -days 365 -nodes -out self.pem -keyout /usr/local/libexec/novnc/utils/websockify/self.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=Global Security/OU=IT Department/CN=vnc"

VNC_PASS=$(openssl rand -base64 20 | md5 | head -c20)
USER_PASS=$(openssl rand -base64 20 | md5 | head -c6)

mkdir /usr/home
ln -s /usr/home /home

pw user add vncserver -c vncserver -s /bin/sh
echo $USER_PASS | pw usermod -n vncserver -h 0
mkdir -p /home/vncserver/.vnc/
chown -R vncserver:vncserver /home/vncserver

su -l vncserver -c "x11vnc -storepasswd ${VNC_PASS} ~/.vnc/passwd"
#su -l vncserver -c "echo ${VNC_PASS} | vncpasswd -f > ~/.vnc/passwd"
chmod 0600 /home/vncserver/.vnc/passwd

#fetch https://raw.githubusercontent.com/SumGuyV5/FreeBSDScripts/master/freebsd_setup.sh
#chmod 755 freebsd_setup.sh

#./freebsd_setup.sh -p -x -d lightdm -f -s -u vncserver -b vncserver 2>/dev/null

sysrc websockify_enable=YES
service websockify start

sysrc x11vnc_enable=YES

service x11vnc start

#openssl req -new -x509 -days 365 -nodes -out self.pem -keyout self.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=Global Security/OU=IT Department/CN=vnc"
#websockify -D --web=/usr/local/libexec/novnc/ --cert=/usr/local/libexec/novnc/utils/websockify/self.pem 6080 localhost:5900

echo -e "test now installed.\n" > /root/PLUGIN_INFO
echo -e "\nYour VNC password is... ${VNC_PASS}\n" >> /root/PLUGIN_INFO
echo -e "\nUser password is... ${USER_PASS}\n" >> /root/PLUGIN_INFO
echo -e "\nGo to $IP_ADDRESS:6080\n" >> /root/PLUGIN_INFO