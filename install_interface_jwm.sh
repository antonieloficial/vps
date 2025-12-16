#!/bin/bash
# install-jwm-filemanager.sh - VERSÃO FINAL CORRIGIDA
echo "=========================================="
echo "  JWM + PCManFM + VNC - INSTALAÇÃO COMPLETA"
echo "  Ubuntu 20.04"
echo "=========================================="

# ============================================
# 1. INSTALAR PACOTES MÍNIMOS
# ============================================
echo "[1/5] Instalando pacotes..."
sudo apt update
sudo apt install -y --no-install-recommends \
    xserver-xorg-core \
    jwm \
    pcmanfm \
    xterm \
    htop \
    wget \
    curl \
    tigervnc-standalone-server \
    feh \
    xfonts-base \
    xfonts-100dpi \
    xfonts-75dpi 2>/dev/null

# ============================================
# 2. CONFIGURAR JWM COM FONTES 14px CORRIGIDO
# ============================================
echo "[2/5] Configurando JWM..."
mkdir -p ~/.jwm

CURRENT_USER=$(whoami)

cat > ~/.jwmrc << JWM
<?xml version="1.0"?>
<JWM>

<!-- TEMA COM FONTES 14px -->
<WindowStyle>
    <Font>-misc-fixed-medium-r-*-*-14-*-*-*-*-*-*-*</Font>
    <Width>1</Width>
    <Height>20</Height>
</WindowStyle>

<MenuStyle>
    <Font>-misc-fixed-medium-r-*-*-14-*-*-*-*-*-*-*</Font>
</MenuStyle>

<TrayButtonStyle>
    <Font>-misc-fixed-medium-r-*-*-14-*-*-*-*-*-*-*</Font>
</TrayButtonStyle>

<TaskListStyle>
    <Font>-misc-fixed-medium-r-*-*-14-*-*-*-*-*-*-*</Font>
    <Active>
        <Foreground>white</Foreground>
        <Background>#2C001E</Background>
    </Active>
</TaskListStyle>

<ClockStyle>
    <Font>-misc-fixed-medium-r-*-*-14-*-*-*-*-*-*-*</Font>
</ClockStyle>

<!-- BARRA DE TAREFAS 30px -->
<Tray x="0" y="-1" height="30" autohide="off">
    <TrayButton label="Menu">root:1</TrayButton>
    <Spacer/>
    <TaskList/>
    <Spacer/>
    <!-- NOME DO USUÁRIO CORRETO (SEM ASPAS EXTRAS) -->
    <TrayButton label="$CURRENT_USER"></TrayButton>
    <Clock format="%H:%M"/>
</Tray>

<!-- MENU PRINCIPAL -->
<RootMenu onroot="1" label="Menu">
    <Menu label="Arquivos">
        <Program label="PCManFM">pcmanfm</Program>
    </Menu>

    <Menu label="Sistema">
        <Program label="Terminal">xterm</Program>
        <Program label="Monitor Sistema">xterm -e htop</Program>
        <Restart label="Reiniciar JWM"/>
    </Menu>

    <Menu label="Utilitarios">
        <Program label="Editor de Texto">xterm -e nano</Program>
        <Program label="Limpar Tela">clear</Program>
    </Menu>

    <Separator/>

    <Menu label="Sair">
        <Program label="Reboot">sudo reboot</Program>
        <Separator/>
        <Exit label="Logout" confirm="true"/>
    </Menu>
</RootMenu>

<!-- MENU RÁPIDO -->
<RootMenu onroot="3">
    <Program label="Gerenciador de Arquivos">pcmanfm</Program>
    <Program label="Terminal">xterm</Program>
    <Separator/>
    <Program label="Monitor Sistema">xterm -e htop</Program>
    <Separator/>
    <Restart label="Reiniciar JWM"/>
    <Program label="Reboot">sudo reboot</Program>
    <Exit label="Sair"/>
</RootMenu>

<!-- ATALHOS -->
<Key key="F1">root:1</Key>
<Key key="F2">exec:pcmanfm</Key>
<Key key="F3">exec:xterm</Key>
<Key key="F4">close</Key>
<Key key="F5">exec:jwm -restart</Key>
<Key key="Alt+Tab">next</Key>
<Key key="Alt+F4">close</Key>

<!-- ÁREAS DE TRABALHO -->
<Desktops width="2" height="1">
    <Desktop name="Arquivos"/>
    <Desktop name="Terminal"/>
</Desktops>

<!-- REGRAS -->
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

echo "  ✅ JWM configurado para usuário: $CURRENT_USER"

# ============================================
# 3. CONFIGURAR PCManFM
# ============================================
echo "[3/5] Configurando PCManFM..."
mkdir -p ~/.config/pcmanfm/default

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
# 4. CONFIGURAR VNC COM JWM CORRETO
# ============================================
echo "[4/5] Configurando VNC..."
mkdir -p ~/.vnc

# Configurar senha VNC (123456)
echo -e "123456\n123456\nn" | vncpasswd >/dev/null 2>&1

# Script xstartup CORRETO que inicia JWM no VNC
cat > ~/.vnc/xstartup << 'VNC'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Definir display correto
export DISPLAY=:1

# Iniciar gerenciador de arquivos como desktop
pcmanfm --desktop &

# Iniciar JWM
exec jwm
VNC
chmod +x ~/.vnc/xstartup

# Script para iniciar VNC CORRETAMENTE
cat > ~/startvnc << 'START'
#!/bin/bash
echo "=== INICIANDO VNC SERVER ==="

# Matar VNC antigo
vncserver -kill :1 2>/dev/null
vncserver -kill :2 2>/dev/null
vncserver -kill :3 2>/dev/null
pkill -f Xvnc 2>/dev/null
sleep 2

# Iniciar novo VNC
echo "Iniciando servidor VNC..."
vncserver :1 -geometry 1280x720 -depth 24 -localhost no -dpi 144

# Aguardar inicialização
sleep 3

# Verificar status
if pgrep Xvnc >/dev/null; then
    IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    echo ""
    echo "✅ VNC CONFIGURADO COM SUCESSO!"
    echo "================================="
    echo "🔗 CONECTE EM: $IP:5901"
    echo "🔑 SENHA: 123456"
    echo "🖥️  DISPLAY: :1"
    echo "👤 USUÁRIO: $CURRENT_USER"
    echo "📁 GERENCIADOR: F2 ou Menu → Arquivos"
    echo "💻 TERMINAL: F3 ou Menu → Sistema → Terminal"
    echo "================================="
    echo ""
    echo "JWM está rodando automaticamente no VNC."
    echo "NÃO execute 'jwm &' no terminal SSH."
else
    echo "❌ ERRO: VNC não iniciou"
    exit 1
fi
START
chmod +x ~/startvnc

# Script para parar VNC
cat > ~/stopvnc << 'STOP'
#!/bin/bash
echo "Parando VNC..."
vncserver -kill :1 2>/dev/null
vncserver -kill :2 2>/dev/null
pkill -f Xvnc 2>/dev/null
echo "✅ VNC parado"
STOP
chmod +x ~/stopvnc

# Wallpaper padrão
sudo mkdir -p /usr/share/backgrounds
sudo sh -c 'echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > /usr/share/backgrounds/default.png'

# Corrigir hora
sudo timedatectl set-timezone $(curl -s http://ip-api.com/line?fields=timezone) && sudo timedatectl set-ntp true && sudo systemctl restart systemd-timesyncd && sleep 3 && sudo hwclock --systohc && echo "✅ Hora automaticamente corrigida!"

# ============================================
# 5. SCRIPTS DE CONTROLE E AJUSTES
# ============================================
echo "[5/5] Criando scripts de controle..."

# Fix para fontes do VNC
cat > ~/fix-vnc-fonts << 'FIX'
#!/bin/bash
echo "Corrigindo fontes do VNC..."
sudo apt install xfonts-base xfonts-100dpi xfonts-75dpi -y 2>/dev/null
echo "✅ Fontes instaladas. Reinicie o VNC: ~/stopvnc && ~/startvnc"
FIX
chmod +x ~/fix-vnc-fonts

# Status do sistema
cat > ~/jwm-status << 'STATUS'
#!/bin/bash
echo "=== STATUS DO SISTEMA ==="
echo "👤 Usuário: $(whoami)"
echo "🧠 RAM: $(free -m | awk '/^Mem:/{print $3}')MB / $(free -m | awk '/^Mem:/{print $2}')MB"
echo ""
echo "=== VNC ==="
if pgrep Xvnc >/dev/null; then
    echo "✅ ATIVO - Display: :1"
    echo "   Porta: 5901"
    echo "   IP: $(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')"
else
    echo "❌ INATIVO"
    echo "   Execute: ~/startvnc"
fi
echo ""
echo "=== JWM ==="
if pgrep jwm >/dev/null; then
    echo "✅ RODANDO (PID: $(pgrep jwm))"
else
    echo "❌ PARADO (será iniciado automaticamente no VNC)"
fi
echo ""
echo "=== COMANDOS ÚTEIS ==="
echo "~/startvnc    - Iniciar interface gráfica"
echo "~/stopvnc     - Parar interface gráfica"
echo "~/fix-vnc-fonts - Corrigir problemas de fonte"
STATUS
chmod +x ~/jwm-status

# Script de ajuda
cat > ~/jwm-help << 'HELP'
#!/bin/bash
echo "=== AJUDA JWM + VNC ==="
echo ""
echo "⚠️  IMPORTANTE: JWM só funciona dentro do VNC"
echo "   NÃO execute 'jwm &' no terminal SSH"
echo ""
echo "📋 FLUXO CORRETO:"
echo "1. ~/startvnc               # Inicia servidor VNC"
echo "2. Conecte com VNC Viewer   # IP:5901, Senha: 123456"
echo "3. Use a interface JWM      # Dentro do VNC"
echo "4. ~/stopvnc                # Quando terminar"
echo ""
echo "🎮 ATALHOS DENTRO DO JWM:"
echo "F1       - Abrir menu"
echo "F2       - PCManFM (gerenciador de arquivos)"
echo "F3       - Terminal"
echo "F5       - Reiniciar JWM"
echo "Botão ≡  - Menu principal"
echo ""
echo "🔧 CONFIGURAÇÃO:"
echo "Fontes: 14px em todos os elementos"
echo "Barra: 30px de altura"
echo "Usuário: $(whoami) mostrado na barra"
echo ""
echo "❓ PROBLEMAS COMUNS:"
echo "- Menu não abre? → Reinicie JWM (F5)"
echo "- Sem ícones? → ~/fix-vnc-fonts"
echo "- VNC não conecta? → ~/stopvnc && ~/startvnc"
HELP
chmod +x ~/jwm-help

# ============================================
# FINALIZAÇÃO
# ============================================
echo ""
echo "=========================================="
echo "✅ INSTALAÇÃO COMPLETA COM SUCESSO!"
echo "=========================================="
echo ""
echo "🎯 ESPECIFICAÇÕES:"
echo "   • Fontes: 14px em TODOS elementos"
echo "   • Barra de tarefas: 30px altura"
echo "   • Usuário: $CURRENT_USER na barra (CORRIGIDO)"
echo "   • Menu limpo, sem ícones/emojis"
echo ""
echo "🚀 PARA INICIAR A INTERFACE:"
echo "   ~/startvnc"
echo ""
echo "🔗 PARA CONECTAR:"
echo "   1. Abra VNC Viewer no seu computador"
echo "   2. Conecte a: [IP_DO_SERVIDOR]:5901"
echo "   3. Senha: 123456"
echo ""
echo "📋 DENTRO DO JWM (no VNC):"
echo "   • Menu → Sistema → Terminal"
echo "   • Menu → Sistema → Monitor Sistema"
echo "   • Menu → Sistema → Reiniciar JWM (F5)"
echo "   • Menu → Sair → Reboot (Instancia)"
echo ""
echo "⚡ COMANDOS ÚTEIS:"
echo "   ~/stopvnc      - Parar interface"
echo "   ~/jwm-status   - Ver status"
echo "   ~/jwm-help     - Ajuda completa"
echo "   ~/fix-vnc-fonts - Corrigir fontes"
echo ""
echo "⚠️  LEMBRETE IMPORTANTE:"
echo "   • JWM funciona APENAS dentro do VNC"
echo "   • NUNCA execute 'jwm &' no terminal SSH"
echo "   • Use ~/startvnc para interface gráfica"
echo ""
echo "=========================================="
