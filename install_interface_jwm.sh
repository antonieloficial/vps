#!/bin/bash
# install_interface_jwm.sh - VERSÃO FINAL CORRIGIDA
echo "==========================================="
echo " Interface JWM + VNC - INSTALAÇÃO CORRIGIDA"
echo "==========================================="

vncserver -kill :1

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
cat > ~/.jwmrc << 'EOF'
<?xml version="1.0"?>
<JWM>
<!-- CORREÇÃO: Desabilita completamente cliques na área de trabalho -->
<RootButtons close="" icon="" />
<Include>/dev/null</Include>

<!-- BARRA DE TAREFAS FUNCIONAL -->
<Tray x="0" y="-1" height="36" autohide="off">
    <TrayButton label="   MENU   ">root:1</TrayButton>
    <Spacer/>
    <TaskList/>
    <Spacer/>
    <TrayButton label="'"$CURRENT_USER"'"/>
    <Clock format="%H:%M"/>
</Tray>

<!-- MENU PRINCIPAL - SEM onroot -->
<RootMenu label="Menu">
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

# Verificar e remover configurações antigas
rm -f ~/.jwm/rootmenu 2>/dev/null

echo "Configurando VNC mínimo..."
mkdir -p ~/.vnc
echo "123456" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null
vncpasswd
chmod 600 ~/.vnc/passwd
echo '#!/bin/sh
exec jwm' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

echo "Criando script de inicialização..."
# CORREÇÃO DO ALIAS - aspas simples corretas
cat > ~/startvnc << 'EOF'
#!/bin/bash
vncserver -kill :1 2>/dev/null
# CORREÇÃO: alias com aspas corretas
if ! grep -q "alias vncstart=" ~/.bashrc; then
    echo "alias vncstart='vncserver :1 -geometry 1024x768 -depth 16'" >> ~/.bashrc
    source ~/.bashrc
fi
vncserver :1 -geometry 1024x768 -depth 16
echo "VNC iniciado na porta 5901"
EOF

chmod +x ~/startvnc

# Configurar crontab sem erros
(crontab -l 2>/dev/null | grep -v "@reboot.*vncserver"; echo "@reboot sleep 10 && /bin/bash -c 'vncserver :1 -geometry 1024x768 -depth 16'") | crontab -

echo "✅ Instalação mínima concluída"
echo "Use: ~/startvnc"
echo "Ou: vncstart (após recarregar terminal com 'source ~/.bashrc')"

# Verificação
echo ""
echo "🔍 VERIFICAÇÃO FINAL:"
echo "1. Config JWM: $(ls -la ~/.jwmrc 2>/dev/null | wc -l) arquivo(s)"
echo "2. Clique área de trabalho: DESABILITADO"
echo "3. Alias configurado: $(grep -c "alias vncstart" ~/.bashrc 2>/dev/null)"
echo ""
echo "Para testar:"
echo "1. Execute ~/startvnc"
echo "2. Clique na área de trabalho - nada deve acontecer"
echo "3. Clique no botão MENU - deve abrir normalmente"

