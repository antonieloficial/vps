#!/bin/bash
# install_interface_jwm.sh - VERSÃO FINAL CORRIGIDA
echo "==========================================="
echo " Interface JWM + VNC - INSTALAÇÃO CORRIGIDA"
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
    xfonts-base \
    fontconfig \
    tightvncserver \
    feh 2>/dev/null

# INSTALAÇÃO MÍNIMA DO JWM 2.4.2
wget -q https://github.com/joewing/jwm/releases/download/v2.4.2/jwm-2.4.2.tar.xz && tar -xf jwm-2.4.2.tar.xz && cd jwm-2.4.2 && ./configure --prefix=/usr --disable-nls --disable-debug --disable-xft --disable-jpeg --disable-png --disable-xpm --disable-xinerama && make CFLAGS="-Os -s" -j2 && sudo make install && cd /tmp && rm -rf jwm-2.4.2* && echo "✅ JWM instalado"

CURRENT_USER=$(whoami)

echo "Configurando JWM..."

mkdir -p ~/.jwm
cat > ~/.jwmrc << EOF
<?xml version="1.0"?>
<JWM>
<!-- BARRA DE TAREFAS FUNCIONAL -->
<Tray x="0" y="-1" height="36" autohide="off">
    <TrayButton label="   MENU   ">root:1</TrayButton>
    <Spacer/>
    <TaskList/>
    <Spacer/>
    <TrayButton label="$CURRENT_USER"/>
    <Clock format="%H:%M"/>
</Tray>

<!-- MENU PRINCIPAL -->
<RootMenu onroot="1" label="Menu">
    <Program label="Htop">xterm -e htop</Program>
    <Program label="Nano">xterm -e nano</Program>
    <Program label="PCManFM">pcmanfm /home</Program>
    <Program label="Terminal">xterm</Program>
    <Restart label="Reiniciar JWM"/>
    <Menu label="Sistema">
        <Program label="Reiniciar Instância" confirm="Deseja realmente reiniciar a instância?">sudo reboot</Program>
        <Exit label="Logout" confirm="true"/>
    </Menu>
</RootMenu>
</JWM>
EOF

echo "Configurando VNC mínimo..."
mkdir -p ~/.vnc
echo "123456" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null
vncpasswd
chmod 600 ~/.vnc/passwd
echo '#!/bin/sh
exec jwm' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo "Criando script de inicialização..."
echo '#!/bin/bash
vncserver -kill :1 2>/dev/null
grep -q "alias vncserver=" ~/.bashrc || echo "alias vncserver='vncserver :1 -geometry 1024x768 -dpi 144'" >> ~/.bashrc && source ~/.bashrc
vncserver :1 -geometry 1024x768 -depth 16' > ~/startvnc
chmod +x ~/startvnc

echo "@reboot sleep 5 && vncserver :1 -geometry 1024x768 -depth 16" | crontab - 2>/dev/null

echo "✅ Instalação mínima concluída"
echo "Use: ~/startvnc"
if strings /usr/bin/jwm 2>/dev/null | grep -q "JWM v2.4.2"; then
    echo "JWM v2.4.2"
else
    echo "JWM (compilação mínima)"
fi
echo "Tamanho: $(ls -lh /usr/bin/jwm | awk '{print $5}')"

# Verificação final
echo ""
echo "🔍 VERIFICAÇÃO FINAL:"
echo "Nome configurado na barra: '$CURRENT_USER'"
echo "Para aplicar: pkill -HUP jwm"
echo "Teste: xterm &"




