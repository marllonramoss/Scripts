#!/bin/bash

# Cores para mensagens
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Função para mostrar mensagens
show_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Função para mostrar avisos
show_warning() {
    echo -e "${YELLOW}AVISO: $1${NC}"
}

# Verificar se está rodando como sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Este script precisa ser executado como sudo${NC}"
    echo "Por favor, execute: sudo ./clean_system_data.sh"
    exit 1
fi

show_message "Iniciando limpeza do System Data"

# 1. Limpar caches do sistema
show_message "Limpando caches do sistema"
rm -rf /Users/$SUDO_USER/Library/Caches/*
rm -rf /Library/Caches/*

# 2. Limpar logs antigos
show_message "Limpando logs antigos"
sudo rm -rf /var/log/*.log
sudo rm -rf /var/log/asl/*.asl
sudo rm -rf /private/var/log/asl/*.asl

# 3. Limpar arquivos temporários
show_message "Limpando arquivos temporários"
sudo rm -rf /private/var/tmp/*
sudo rm -rf /private/var/folders/*
sudo rm -rf /Users/$SUDO_USER/Library/Logs/*

# 4. Limpar caches de desenvolvimento
show_message "Limpando caches de desenvolvimento"
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Developer/Xcode/Archives
rm -rf ~/Library/Developer/Xcode/iOS Device Logs
rm -rf ~/Library/Developer/CoreSimulator/Devices/*

# 5. Limpar caches de aplicativos
show_message "Limpando caches de aplicativos"
rm -rf ~/Library/Application\ Support/*/Cache
rm -rf ~/Library/Application\ Support/*/Caches

# 6. Limpar downloads incompletos
show_message "Limpando downloads incompletos"
rm -rf ~/Library/Application\ Support/*/Cache/downloads
rm -rf ~/Library/Application\ Support/*/Cache/TemporaryItems

# 7. Limpar caches do Xcode
show_message "Limpando caches do Xcode"
xcrun simctl delete unavailable 2>/dev/null
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*

# 8. Limpar caches do CocoaPods
show_message "Limpando caches do CocoaPods"
rm -rf ~/Library/Caches/CocoaPods
rm -rf ~/.cocoapods

# 9. Limpar caches do Homebrew (se existir no sistema)
show_message "Limpando caches do Homebrew"
brew cleanup --prune=all 2>/dev/null
rm -rf ~/Library/Caches/Homebrew 2>/dev/null

# 10. Limpar caches do npm (se existir no sistema)
show_message "Limpando caches do npm"
npm cache clean --force 2>/dev/null
rm -rf ~/.npm 2>/dev/null

# 11. Limpar caches do Yarn (se existir no sistema)
show_message "Limpando caches do Yarn"
yarn cache clean 2>/dev/null
rm -rf ~/Library/Caches/yarn 2>/dev/null

# 12. Limpar caches do pip (se existir no sistema)
show_message "Limpando caches do pip"
rm -rf ~/Library/Caches/pip 2>/dev/null

# 13. Limpar caches do Docker (se existir)
show_message "Limpando caches do Docker"
docker system prune -af 2>/dev/null

# 14. Limpar caches do VS Code
show_message "Limpando caches do VS Code"
rm -rf ~/Library/Application\ Support/Code/Cache
rm -rf ~/Library/Application\ Support/Code/CachedData
rm -rf ~/Library/Application\ Support/Code/CachedExtensions

# 15. Limpar caches do Terminal
show_message "Limpando histórico do terminal"
rm -rf ~/.zsh_history
rm -rf ~/.bash_history
rm -rf ~/.node_repl_history

# 16. Limpar caches do Spotlight
show_message "Reconstruindo índice do Spotlight"
sudo mdutil -E / >/dev/null 2>&1

# 17. Limpar caches do sistema
show_message "Limpando caches do sistema"
sudo periodic daily weekly monthly

# 18. Limpar logs do sistema
show_message "Limpando logs do sistema"
sudo rm -rf /private/var/log/*

# Mostrar espaço liberado
show_message "Verificando espaço em disco"
df -h /

show_message "Limpeza concluída!"
show_warning "Recomenda-se reiniciar o computador para aplicar todas as alterações." 