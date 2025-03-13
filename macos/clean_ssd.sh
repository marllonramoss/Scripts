#!/bin/bash

# Cores para mensagens
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para mostrar mensagens
show_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Função para mostrar avisos
show_warning() {
    echo -e "${YELLOW}AVISO: $1${NC}"
}

# Função para mostrar erros
show_error() {
    echo -e "${RED}ERRO: $1${NC}"
}

# Função para confirmar ação
confirm() {
    read -p "$(echo -e ${YELLOW}"$1 [s/n]: "${NC})" choice
    case "$choice" in 
        s|S ) return 0;;
        * ) return 1;;
    esac
}

# Verificar se está rodando como sudo
if [ "$EUID" -ne 0 ]; then 
    show_error "Este script precisa ser executado como sudo"
    echo "Por favor, execute: sudo ./clean_ssd.sh"
    exit 1
fi

# Aviso inicial
show_warning "Este script irá remover todo o ambiente de desenvolvimento do seu SSD."
show_warning "Certifique-se de que seu ambiente no HD externo está funcionando corretamente."
show_warning "FAÇA BACKUP de dados importantes antes de continuar!"
echo ""

if ! confirm "Você tem certeza que quer continuar?"; then
    echo "Operação cancelada."
    exit 0
fi

# Criar backup do .zshrc
show_message "Criando backup do .zshrc"
cp /Users/$SUDO_USER/.zshrc /Users/$SUDO_USER/.zshrc.backup.$(date +%Y%m%d)

# Função para limpar Node.js
clean_node() {
    show_message "Removendo Node.js, NPM e Yarn"
    rm -rf /Users/$SUDO_USER/.nvm
    rm -rf /Users/$SUDO_USER/.npm
    rm -rf /Users/$SUDO_USER/.node-gyp
    rm -rf /Users/$SUDO_USER/.yarn
    rm -rf /Users/$SUDO_USER/.yarnrc
    rm -rf /Users/$SUDO_USER/.config/yarn
    rm -rf /usr/local/lib/node_modules
    rm -rf /usr/local/bin/node
    rm -rf /usr/local/bin/npm
    rm -rf /usr/local/bin/yarn
    rm -rf /usr/local/bin/yarnpkg
}

# Função para limpar Homebrew
clean_homebrew() {
    show_message "Removendo Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || true
    rm -rf /usr/local/Homebrew
    rm -rf /usr/local/Caskroom
    rm -rf /usr/local/Cellar
}

# Função para limpar Python
clean_python() {
    show_message "Removendo Python e ambientes virtuais"
    rm -rf /Users/$SUDO_USER/.virtualenvs
    rm -rf /Users/$SUDO_USER/.pip
    rm -rf /Users/$SUDO_USER/Library/Caches/pip
    rm -rf /Users/$SUDO_USER/.pyenv
    rm -rf /Library/Python/*
}

# Função para limpar Docker
clean_docker() {
    show_message "Removendo dados do Docker"
    osascript -e 'quit app "Docker"' || true
    rm -rf /Users/$SUDO_USER/Library/Containers/com.docker.docker
    rm -rf /Users/$SUDO_USER/Library/Application\ Support/Docker\ Desktop
    rm -rf /Users/$SUDO_USER/.docker
}

# Função para limpar VS Code
clean_vscode() {
    show_message "Removendo dados do VS Code"
    rm -rf /Users/$SUDO_USER/Library/Application\ Support/Code
    rm -rf /Users/$SUDO_USER/.vscode
}

# Função para limpar Ollama
clean_ollama() {
    show_message "Removendo Ollama"
    killall ollama || true
    rm -rf /usr/local/bin/ollama
    rm -rf /Users/$SUDO_USER/.ollama
}

# Função para limpar caches de desenvolvimento
clean_caches() {
    show_message "Limpando caches de desenvolvimento"
    rm -rf /Users/$SUDO_USER/Library/Caches/com.apple.dt.Xcode
    rm -rf /Users/$SUDO_USER/Library/Developer
    rm -rf /Users/$SUDO_USER/Library/Caches/pip
}

# Função para limpar configurações do shell
clean_shell_config() {
    show_message "Limpando configurações do shell"
    sed -i '' '/# NVM Configuration/,/# End NVM Configuration/d' /Users/$SUDO_USER/.zshrc
    sed -i '' '/# Homebrew Configuration/,/# End Homebrew Configuration/d' /Users/$SUDO_USER/.zshrc
    sed -i '' '/# Python Configuration/,/# End Python Configuration/d' /Users/$SUDO_USER/.zshrc
    sed -i '' '/# VS Code Configuration/,/# End VS Code Configuration/d' /Users/$SUDO_USER/.zshrc
    sed -i '' '/# Ollama Configuration/,/# End Ollama Configuration/d' /Users/$SUDO_USER/.zshrc
}

# Menu de seleção
show_message "O que você deseja limpar?"
echo "1. Tudo"
echo "2. Apenas Node.js"
echo "3. Apenas Homebrew"
echo "4. Apenas Python"
echo "5. Apenas Docker"
echo "6. Apenas VS Code"
echo "7. Apenas Ollama"
echo "0. Sair"

read -p "Opção: " option

case $option in
    1)
        clean_node
        clean_homebrew
        clean_python
        clean_docker
        clean_vscode
        clean_ollama
        clean_caches
        clean_shell_config
        ;;
    2)
        clean_node
        ;;
    3)
        clean_homebrew
        ;;
    4)
        clean_python
        ;;
    5)
        clean_docker
        ;;
    6)
        clean_vscode
        ;;
    7)
        clean_ollama
        ;;
    0)
        show_message "Saindo..."
        exit 0
        ;;
    *)
        show_error "Opção inválida!"
        exit 1
        ;;
esac

# Mostrar espaço liberado
show_message "Espaço em disco antes e depois da limpeza"
df -h /

show_message "Limpeza concluída!"
show_warning "Por favor, reinicie seu terminal ou execute 'source ~/.zshrc' para aplicar as mudanças."
show_warning "Verifique se seu ambiente no HD externo está funcionando corretamente." 