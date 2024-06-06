#!/bin/bash

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar GNOME y utilidades
sudo apt install ubuntu-desktop -y

# Instalar y configurar VNC
sudo apt install x11vnc -y
mkdir -p /home/root/.vnc
x11vnc -storepasswd /home/root/.vnc/passwd

# Crear archivo de servicio para x11vnc
sudo bash -c 'cat > /etc/systemd/system/x11vnc.service <<EOL
[Unit]
Description=VNC Server for X11
Requires=graphical.target
After=graphical.target

[Service]
ExecStart=/bin/bash -c "/usr/bin/x11vnc -auth guess -display :0 -forever -noxfixes -noxdamage -repeat -rfbauth /home/$USER/.vnc/passwd -rfbport 5900 -shared"
RestartSec=5
Restart=always
User=root

[Install]
WantedBy=graphical.target
EOL'

# Habilitar y arrancar el servicio x11vnc
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service

# Instalar y configurar xrdp
sudo apt install xrdp -y

# Configurar xrdp para usar GNOME
sudo bash -c 'cat > /etc/xrdp/startwm.sh <<EOL
#!/bin/sh
if [ -r /etc/profile ]; then
    . /etc/profile
fi
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
. /etc/X11/Xsession
EOL'

# Habilitar y arrancar el servicio xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Configurar el firewall
sudo ufw allow 5900
sudo ufw allow 3389

echo "Configuración completa. Ahora puedes conectarte a través de VNC en el puerto 5900 y RDP en el puerto 3389."
