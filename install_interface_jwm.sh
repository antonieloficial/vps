#!/bin/bash
# install_interface_jwm.shh - VERSÃO FINAL
echo "==========================================="
echo " Interface JWM + VNC - INSTALAÇÃO COMPLETA "
echo "==========================================="
echo.
echo "Atualizando pacotes e otimizando o sistema..."
echo.
sudo apt update
sudo apt purge plymouth snapd modemmanager -y

# Corrigir hora
sudo timedatectl set-timezone $(curl -s http://ip-api.com/line?fields=timezone) && sudo timedatectl set-ntp true && sudo systemctl restart systemd-timesyncd && sleep 3 && sudo hwclock --systohc

echo "Instalando programas essenciais..."
echo.
sudo apt install -y --no-install-recommends \
    xserver-xorg-core \
    jwm \
    pcmanfm \
    xterm \
    htop \
    wget \
    curl \
	tightvncserver \
    tigervnc-standalone-server \
    feh 2>/dev/null

CURRENT_USER=$(whoami)

echo "Configurando JWM..."
echo.
mkdir -p ~/.jwm
cat > ~/.jwmrc << JWM
<?xml version="1.0"?>
<JWM>
<Tray x="0" y="-1" height="40">
    <TrayButton label="   MENU   ">root:1</TrayButton>
    <Spacer/>
    <TaskList/>
    <Spacer/>
    <TrayButton label="$CURRENT_USER">root:3</TrayButton>
    <Clock format="%H:%M"/>
</Tray>
<RootMenu onroot="1" label="Menu">
    <Program label="PCManFM">pcmanfm /home</Program>
    <Program label="Terminal">xterm</Program>
    <Restart label="Reiniciar JWM"/>
    <Program label="Reboot Instância" confirm="true">sudo reboot</Program>
    <Exit label="Logout" confirm="true"/>
</RootMenu>
<RootMenu onroot="3">
    <Program label="PCManFM">pcmanfm /home</Program>
    <Program label="Terminal">xterm</Program>
    <Restart label="Reiniciar JWM"/>
    <Program label="Reboot Instância" confirm="true">sudo reboot</Program>
    <Exit label="Sair" confirm="true"/>
</RootMenu>
</JWM>
JWM

echo "Configurando VNC..."
echo.
mkdir -p ~/.vnc
echo -e "123456\n123456\nn" | vncpasswd >/dev/null 2>&1
echo '#!/bin/bash
vncserver :1 -geometry 1280x720 -dpi 144
pcmanfm --desktop &
exec jwm' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo "Criando script de inicialização..."
echo.
echo '#!/bin/bash
vncserver -kill :1 2>/dev/null
sleep 1
grep -q "alias vncserver=" ~/.bashrc || echo "alias vncserver='vncserver :1 -geometry 1280x720 -dpi 144'" >> ~/.bashrc && source ~/.bashrc
vncserver :1 -geometry 1280x720 -dpi 144
echo "✅ VNC iniciado"
echo "Conecte em: $(hostname -I | awk "{print \$1}"):5901"
echo "Senha: 123456"' > ~/startvnc
chmod +x ~/startvnc

# Inicializar vncserver com o sistema
echo "@reboot sleep 10 && vncserver :1 -geometry 1280x720 -dpi 144" | crontab -

vncserver -kill :1
vncserver :1 -geometry 1280x720 -dpi 144

echo "✅ Concluído"
echo "Use: ~/startvnc"









