#!/bin/bash
# install-jwm-filemanager.sh
echo "=========================================="
echo "  JWM + MENUS + BARRA + GERENCIADOR ARQUIVOS"
echo "  Consumo: ~55MB RAM | Ubuntu 20.04"
echo "=========================================="

# ============================================
# 1. INSTALAR PACOTES MÍNIMOS + PCManFM
# ============================================
echo "[1/5] Instalando pacotes..."
sudo apt install -y --no-install-recommends \
    xserver-xorg-core \
    jwm \
    pcmanfm \
    xterm \
    htop \
    wget \
    curl \
    tigervnc-standalone-server \
    tightvncserver \
    feh 2>/dev/null

# ============================================
# 2. CONFIGURAR JWM COM PCManFM NO MENU
# ============================================
echo "[2/5] Configurando JWM com gerenciador de arquivos..."
mkdir -p ~/.jwm

cat > ~/.jwmrc << 'JWM'
<?xml version="1.0"?>
<JWM>

<!-- TEMA SIMPLES -->
<WindowStyle>
    <Font>-misc-fixed-medium-r-*-*-10-*-*-*-*-*-*-*</Font>
    <Width>1</Width>
    <Height>20</Height>
</WindowStyle>

<!-- BARRA DE TAREFAS -->
<Tray x="0" y="-1" height="24" autohide="off">
    <TrayButton label="≡">root:1</TrayButton>
    <Spacer/>
    <TaskList/>
    <Spacer/>
    <Clock format="%H:%M"/>
</Tray>

<!-- MENU PRINCIPAL (CLIQUE NO BOTÃO ≡) -->
<RootMenu onroot="1" label="Menu">
    <!-- GERENCIADOR DE ARQUIVOS -->
    <Menu label="📁 Arquivos" icon="folder.png">
        <Program label="PCManFM (Interface)" icon="file-manager.png">pcmanfm</Program>
        <Program label="PCManFM Desktop" icon="desktop.png">pcmanfm --desktop</Program>
        <Separator/>
        <Program label="Midnight Commander" icon="terminal.png">xterm -e mc</Program>
        <Program label="Listar Arquivos" icon="terminal.png">xterm -e ls -la</Program>
    </Menu>
    
    <!-- TERMINAIS -->
    <Menu label="📟 Terminais" icon="terminal.png">
        <Program label="XTerm" icon="terminal.png">xterm</Program>
        <Program label="Terminal com Htop" icon="monitor.png">xterm -e htop</Program>
        <Program label="Terminal Root" icon="root.png">xterm -e "sudo -i"</Program>
    </Menu>
    
    <!-- SISTEMA -->
    <Menu label="⚙️ Sistema" icon="system.png">
        <Program label="📊 Monitor Sistema" icon="monitor.png">xterm -e htop</Program>
        <Program label="💾 RAM: $(free -m | awk '/^Mem:/{print $3}')MB" icon="memory.png">xterm -e free -m</Program>
        <Program label="🌐 IP: $(hostname -I | awk '{print $1}')" icon="network.png">xterm -e ip addr</Program>
        <Separator/>
        <Restart label="🔄 Reiniciar JWM" icon="refresh.png"/>
    </Menu>
    
    <!-- VNC -->
    <Menu label="🔌 VNC" icon="vnc.png">
        <Program label="▶️ Iniciar VNC" icon="start.png">~/startvnc</Program>
        <Program label="⏹️ Parar VNC" icon="stop.png">vncserver -kill :1</Program>
        <Program label="📡 Status VNC" icon="info.png">~/jwm-status</Program>
    </Menu>
    
    <Separator/>
    
    <!-- UTILIDADES -->
    <Menu label="🛠️ Utilitários" icon="tools.png">
        <Program label="🎨 Mudar Wallpaper" icon="image.png">feh --randomize --bg-fill /usr/share/backgrounds/* 2>/dev/null || echo "Use: feh --bg-fill imagem.jpg"</Program>
        <Program label="📝 Editor de Texto" icon="editor.png">xterm -e nano</Program>
        <Program label="🌐 Navegador Web" icon="browser.png">xterm -e lynx</Program>
        <Program label="🧹 Limpar Tela" icon="clean.png">clear</Program>
    </Menu>
    
    <Separator/>
    
    <!-- SAIR -->
    <Menu label="🚪 Sair" icon="exit.png">
        <Exit label="Logout" confirm="true" icon="logout.png"/>
    </Menu>
</RootMenu>

<!-- MENU RÁPIDO (CLIQUE DIREITO) -->
<RootMenu onroot="3">
    <Program label="📁 Gerenciador de Arquivos">pcmanfm</Program>
    <Program label="📟 Terminal">xterm</Program>
    <Separator/>
    <Program label="📊 Monitor Sistema">xterm -e htop</Program>
    <Separator/>
    <Restart label="🔄 Reiniciar JWM"/>
    <Exit label="🚪 Sair"/>
</RootMenu>

<!-- ATALHOS DE TECLADO -->
<Key key="F1">root:1</Key>
<Key key="F2">exec:pcmanfm</Key>
<Key key="F3">exec:xterm</Key>
<Key key="F4">close</Key>
<Key key="F5">exec:jwm -restart</Key>
<Key key="Alt+Tab">next</Key>
<Key key="Alt+F4">close</Key>
<Key key="Print">exec:scrot screenshot_%Y-%m-%d_%H-%M-%S.png</Key>

<!-- 2 ÁREAS DE TRABALHO -->
<Desktops width="2" height="1">
    <Desktop name="📁 Arquivos"/>
    <Desktop name="📟 Terminal"/>
</Desktops>

<!-- REGRAS PARA APLICATIVOS -->
<Group>
    <Class>Pcmanfm</Class>
    <Option>vmax</Option>
</Group>
<Group>
    <Class>XTerm</Class>
    <Option>center</Option>
</Group>

</JWM>
JWM

# ============================================
# 3. CONFIGURAR PCManFM (GERENCIADOR ARQUIVOS)
# ============================================
echo "[3/5] Configurando PCManFM..."
mkdir -p ~/.config/pcmanfm/default

# Configuração mínima do PCManFM
cat > ~/.config/pcmanfm/default/pcmanfm.conf << 'PCManFM'
[config]
single_click=0
use_trash=1
confirm_del=1
confirm_trash=0
terminal=xterm

[ui]
big_icon_size=24
small_icon_size=16
show_thumbnail=0
thumbnail_size=128
PCManFM

# Configurar ícones no desktop
cat > ~/.config/pcmanfm/default/desktop-items-0.conf << 'DESKTOP'
[*]
wallpaper_mode=1
wallpaper=/usr/share/backgrounds/default.png
desktop_bg=#2C001E
desktop_fg=#FFFFFF
desktop_shadow=#000000
show_wm_menu=0
DESKTOP

# ============================================
# 4. CONFIGURAR VNC + WALLPAPER
# ============================================
echo "[4/5] Configurando VNC e wallpaper..."
mkdir -p ~/.vnc

# Senha: 123456
echo -e "123456\n123456\nn" | vncpasswd

cat > ~/.vnc/xstartup << 'VNC'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Iniciar gerenciador de arquivos como desktop
pcmanfm --desktop &

# Iniciar JWM
exec jwm
VNC
chmod +x ~/.vnc/xstartup

# Script de inicialização VNC
cat > ~/startvnc << 'START'
#!/bin/bash
vncserver -kill :1 2>/dev/null
vncserver :1 -geometry 1024x768 -depth 24 -localhost no
echo "✅ VNC: $(curl -s ifconfig.me):5900"
echo "🔑 Senha: 123456"
echo "📁 Gerenciador de arquivos: F2 ou Menu → Arquivos"
START
chmod +x ~/startvnc

# Baixar wallpaper padrão
sudo mkdir -p /usr/share/backgrounds
sudo sh -c 'echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > /usr/share/backgrounds/default.png'

# ============================================
# 5. CRIAR SCRIPTS DE CONTROLE
# ============================================
echo "[5/5] Criando scripts de controle..."

# Script de status
cat > ~/jwm-status << 'STATUS'
#!/bin/bash
echo "=== JWM STATUS ==="
echo "RAM: $(free -m | awk '/^Mem:/{print $3}')MB"
echo "PCManFM: $(pgrep pcmanfm >/dev/null && echo ✅ || echo ❌)"
echo "JWM: $(pgrep jwm >/dev/null && echo ✅ || echo ❌)"
echo ""
if pgrep Xvnc >/dev/null; then
    echo "✅ VNC: $(curl -s ifconfig.me):5900"
else
    echo "❌ VNC INATIVO"
fi
STATUS
chmod +x ~/jwm-status

# Script para abrir gerenciador de arquivos
cat > ~/open-files << 'FILES'
#!/bin/bash
echo "Abrindo gerenciador de arquivos..."
pcmanfm &
echo "Use F2 para abrir novamente"
FILES
chmod +x ~/open-files

# ============================================
# FINALIZAÇÃO
# ============================================
echo ""
echo "=========================================="
echo "✅ JWM + PCManFM INSTALADO COM SUCESSO!"
echo "=========================================="
echo ""
echo "🎯 CONSUMO: ~55MB RAM"
echo ""
echo "🚀 PARA INICIAR VNC:"
echo "   ~/startvnc"
echo ""
echo "🎮 CONTROLES PRINCIPAIS:"
echo "   • Botão '≡' na barra → Menu completo"
echo "   • Clique direito na área → Menu rápido"
echo "   • F1 → Menu, F2 → Gerenciador de Arquivos"
echo "   • F3 → Terminal, F5 → Reiniciar JWM"
echo "   • Menu → Arquivos → PCManFM"
echo ""
echo "📁 GERENCIADOR DE ARQUIVOS:"
echo "   • Interface gráfica completa"
echo "   • Navegação com mouse"
echo "   • Copiar/Mover/Excluir arquivos"
echo "   • Modo desktop disponível"
echo ""
echo "🔗 REALVNC VIEWER:"
echo "   $(curl -s ifconfig.me):5900"
echo "   Senha: 123456"
echo ""
echo "📊 STATUS: ~/jwm-status"
echo "📁 ABRIR ARQUIVOS: ~/open-files"

echo "=========================================="

