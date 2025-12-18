#!/bin/bash
# install_interface_jwm.shh - VERSÃO MÍNIMA
echo "==========================================="
echo " Interface JWM + VNC - INSTALAÇÃO MÍNIMA  "
echo "==========================================="

echo "Atualizando pacotes..."

sudo apt update
sudo apt purge plymouth snapd modemmanager -y

# Corrigir hora (sem curl pesado)
sudo timedatectl set-timezone America/Sao_Paulo 2>/dev/null || true
sudo timedatectl set-ntp true

echo "Instalando programas mínimos..."
sudo apt install -y --no-install-recommends \
    build-essential \
    libx11-dev \
    pcmanfm \
    xterm \
    htop \
    wget \
    xz-utils \
    tightvncserver \
    feh 2>/dev/null

# INSTALAÇÃO MÍNIMA DO JWM 2.4.2
wget -q https://github.com/joewing/jwm/releases/download/v2.4.2/jwm-2.4.2.tar.xz && tar -xf jwm-2.4.2.tar.xz && cd jwm-2.4.2 && ./configure --prefix=/usr --disable-nls --disable-debug --disable-xft --disable-jpeg --disable-png --disable-xpm --disable-xinerama && make CFLAGS="-Os -s" -j2 && sudo make install && cd /tmp && rm -rf jwm-2.4.2* && echo "✅ JWM $(jwm -version 2>&1 | head -1) instalado. Tamanho: $(ls -lh /usr/bin/jwm | awk '{print $5}')"

CURRENT_USER=$(whoami)

echo "Configurando JWM..."

mkdir -p ~/.jwm
cat > ~/.jwmrc << JWM
<?xml version="1.0"?>
<JWM>
<Tray x="0" y="-1" height="40">
    <TrayButton label="   MENU   ">root:1</TrayButton>
    <Spacer/>
    <TaskList/>
    <Spacer/>
    <TrayButton label="$CURRENT_USER"/>
    <Clock format="%H:%M"/>
</Tray>
<RootMenu onroot="1" label="Menu">
    <Program label="Htop">xterm -e htop</Program>
    <Program label="Nano">xterm -e nano</Program>
    <Program label="PCManFM">pcmanfm /home</Program>
    <Program label="Terminal">xterm</Program>
    <Restart label="Reiniciar JWM"/>
    <Menu label="Sistema">
        <Program label="Reiniciar Instância" confirm="Deseja realmente reiniciar a instância?">sudo reboot</Program>
    </Menu>
    <Exit label="Logout" confirm="true"/>
</RootMenu>
</JWM>
JWM

echo "Configurando VNC mínimo..."
mkdir -p ~/.vnc
echo "123456" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null
chmod 600 ~/.vnc/passwd
echo '#!/bin/sh
exec jwm' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo "Criando script de inicialização..."
echo '#!/bin/bash
vncserver -kill :1 2>/dev/null
vncserver :1 -geometry 1024x768 -depth 16' > ~/startvnc
chmod +x ~/startvnc

echo "@reboot sleep 5 && vncserver :1 -geometry 1024x768 -depth 16" | crontab - 2>/dev/null

echo "✅ Instalação mínima concluída"
echo "Use: ~/startvnc"
echo "JWM: $(jwm -version 2>&1 | head -1)"
