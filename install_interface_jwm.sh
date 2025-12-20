#!/bin/bash
# install_interface_jwm.shh - VERSÃO FINAL
echo "==========================================="
echo " Interface JWM + VNC - INSTALAÇÃO COMPLETA "
echo "==========================================="

echo "Atualizando pacotes e otimizando o sistema..."
sudo apt update
sudo apt purge plymouth snapd modemmanager -y
vncserver -kill :1
# Corrigir hora
sudo timedatectl set-timezone $(curl -s http://ip-api.com/line?fields=timezone) && sudo timedatectl set-ntp true && sudo systemctl restart systemd-timesyncd && sleep 3 && sudo hwclock --systohc

echo "Instalando programas essenciais..."
sudo apt install -y --no-install-recommends \
    xserver-xorg-core \
    pcmanfm \
    xterm \
    htop \
    wget \
    curl \
    x11-xserver-utils \
    tigervnc-standalone-server \
    feh 2>/dev/null

CURRENT_USER=$(whoami)

echo "Instalando JWM 2.4.2"
rm -rf jwm-install
# mkdir jwm-install && cd jwm-install
wget https://github.com/joewing/jwm/releases/download/v2.4.2/jwm-2.4.2.tar.xz
tar -xf jwm-2.4.2.tar.xz
cd jwm-2.4.2
./configure --prefix=/usr/local
make && cd
sudo make install
sudo ln -sf /usr/local/bin/jwm /usr/bin/jwm  # Cria link simbólico
#rm -f jwm-2.4.2.tar.xz
#rm -rf jwm-2.4.2

echo "Configurando Barra de Tarefas"
#rm -f ~/.jwmrc
cat > ~/.jwmrc << EOF
<?xml version="1.0"?>
<JWM>
<Tray x="0" y="-1" height="40">
    <TrayButton label="   MENU   ">root:1</TrayButton>
    <Spacer/>
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
        <Program label="Reiniciar">xterm -title "Reiniciando..." -e "echo 'Reiniciando sistema em 3 segundos...'; sleep 3; sudo reboot"</Program>
    </Menu>
</RootMenu>
</JWM>
EOF

# Mudar cor de fundo do desktop
setsid bash -c '
export DISPLAY=":1" && \
COLOR="#111836" && \
xsetroot -solid "$COLOR" && \
pkill -9 pcmanfm 2>/dev/null; \
sleep 0.5 && \
rm -f ~/.config/pcmanfm/default/desktop-items-*.conf && \
echo "[*]" > ~/.config/pcmanfm/default/desktop-items-0.conf && \
echo "wallpaper=none" >> ~/.config/pcmanfm/default/desktop-items-0.conf && \
echo "wallpaper_mode=none" >> ~/.config/pcmanfm/default/desktop-items-0.conf && \
echo "desktop_bg=$COLOR" >> ~/.config/pcmanfm/default/desktop-items-0.conf && \
pcmanfm --desktop --wallpaper-mode=none --set-wallpaper="none"
' </dev/null >/dev/null 2>&1 &

sudo apt install tightvncserver tigervnc-standalone-server -y    

echo "Configurando VNC..."
mkdir -p ~/.vnc
echo -e "123456\n123456\nn" | vncpasswd >/dev/null 2>&1
echo '#!/bin/bash
vncserver :1 -geometry 1280x720 -dpi 144
pcmanfm --desktop &
exec jwm' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo "Criando script de inicialização..."
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














