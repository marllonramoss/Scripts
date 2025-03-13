#!/bin/bash

# Script para configurar ambiente de desenvolvimento no HD externo
# Criado para macOS Sonoma

# Defina o caminho do seu HD externo aqui
HD_PATH="/Volumes/hd-mac"

# Cores para mensagens
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para verificar se o HD está conectado
check_hd() {
  if [ ! -d "$HD_PATH" ]; then
    echo -e "${RED}HD externo não encontrado em $HD_PATH${NC}"
    echo -e "${YELLOW}Por favor, conecte seu HD externo e execute o script novamente.${NC}"
    exit 1
  fi
}

# Função para criar diretórios
create_directories() {
  echo -e "${GREEN}Criando estrutura de diretórios no HD externo...${NC}"
  
  # Diretório principal
  mkdir -p "$HD_PATH/dev_environment"
  
  # Diretórios específicos
  mkdir -p "$HD_PATH/dev_environment/node"
  mkdir -p "$HD_PATH/dev_environment/npm-global"
  mkdir -p "$HD_PATH/dev_environment/homebrew"
  mkdir -p "$HD_PATH/dev_environment/python"
  mkdir -p "$HD_PATH/dev_environment/python/virtualenvs"
  mkdir -p "$HD_PATH/dev_environment/ruby"
  mkdir -p "$HD_PATH/dev_environment/docker"
  mkdir -p "$HD_PATH/dev_environment/vscode"
  mkdir -p "$HD_PATH/dev_environment/ollama"
  mkdir -p "$HD_PATH/dev_environment/ollama/models"
  
  echo -e "${GREEN}Diretórios criados com sucesso!${NC}"
}

# Função para configurar o Node.js (NVM) e Yarn
setup_node() {
  echo -e "${GREEN}Configurando Node.js (NVM) e Yarn no HD externo...${NC}"
  
  # Configurar NVM
  export NVM_DIR="$HD_PATH/dev_environment/node/nvm"
  
  # Criar diretório para o Yarn
  mkdir -p "$HD_PATH/dev_environment/yarn"
  
  # Instalar NVM se não existir
  if [ ! -d "$NVM_DIR" ]; then
    mkdir -p "$NVM_DIR"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | PROFILE=/dev/null bash
    
    # Copiar os arquivos do NVM para o HD
    cp -R "$HOME/.nvm/"* "$NVM_DIR/" 2>/dev/null
    
    # Remover NVM do local padrão
    rm -rf "$HOME/.nvm" 2>/dev/null
  fi
  
  # Adicionar configurações ao .zshrc
  echo -e "${YELLOW}Adicionando configurações do Node.js e Yarn ao .zshrc...${NC}"
  
  # Remover configurações antigas se existirem
  sed -i '' '/# NVM Configuration/,/# End NVM Configuration/d' "$HOME/.zshrc" 2>/dev/null
  sed -i '' '/# Yarn Configuration/,/# End Yarn Configuration/d' "$HOME/.zshrc" 2>/dev/null
  
  cat >> "$HOME/.zshrc" << EOF
# NVM Configuration
export NVM_DIR="$HD_PATH/dev_environment/node/nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Yarn Configuration
export YARN_CONFIG_PREFIX="$HD_PATH/dev_environment/yarn"
export PATH="\$YARN_CONFIG_PREFIX/bin:\$PATH"
export YARN_CACHE_FOLDER="$HD_PATH/dev_environment/yarn/cache"
# End NVM Configuration
EOF

  echo -e "${GREEN}Node.js e Yarn configurados com sucesso!${NC}"
  echo -e "${YELLOW}Para instalar Node.js, execute: 'source ~/.zshrc && nvm install node'${NC}"
  echo -e "${YELLOW}Para instalar Yarn, execute: 'npm install -g yarn'${NC}"
}

# Função para configurar o Homebrew
setup_homebrew() {
  echo -e "${GREEN}Configurando Homebrew no HD externo...${NC}"
  
  BREW_DIR="$HD_PATH/dev_environment/homebrew"
  
  # Verificar se o Homebrew já está instalado no sistema
  if command -v brew &>/dev/null; then
    echo -e "${YELLOW}Homebrew já está instalado no sistema.${NC}"
    echo -e "${YELLOW}Recomendamos desinstalar o Homebrew atual antes de continuar.${NC}"
    echo -e "${YELLOW}Você pode desinstalar com: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)\"${NC}"
    read -p "Deseja continuar mesmo assim? (s/n): " choice
    if [ "$choice" != "s" ]; then
      echo -e "${YELLOW}Configuração do Homebrew cancelada.${NC}"
      return
    fi
  fi
  
  # Instalar Homebrew no HD externo
  mkdir -p "$BREW_DIR" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_DIR"
  
  # Adicionar configurações ao .zshrc
  echo -e "${YELLOW}Adicionando configurações do Homebrew ao .zshrc...${NC}"
  
  # Remover configurações antigas se existirem
  sed -i '' '/# Homebrew Configuration/,/# End Homebrew Configuration/d' "$HOME/.zshrc" 2>/dev/null
  
  cat >> "$HOME/.zshrc" << EOF
# Homebrew Configuration
export HOMEBREW_PREFIX="$BREW_DIR"
export HOMEBREW_CELLAR="$BREW_DIR/Cellar"
export HOMEBREW_REPOSITORY="$BREW_DIR"
export PATH="$BREW_DIR/bin:$BREW_DIR/sbin:\$PATH"
export MANPATH="$BREW_DIR/share/man:\$MANPATH"
export INFOPATH="$BREW_DIR/share/info:\$INFOPATH"
# End Homebrew Configuration
EOF

  echo -e "${GREEN}Homebrew configurado com sucesso!${NC}"
  echo -e "${YELLOW}Para usar o Homebrew, execute: 'source ~/.zshrc'${NC}"
}

# Função para configurar Python
setup_python() {
  echo -e "${GREEN}Configurando Python no HD externo...${NC}"
  
  PYTHON_DIR="$HD_PATH/dev_environment/python"
  
  # Adicionar configurações ao .zshrc
  echo -e "${YELLOW}Adicionando configurações do Python ao .zshrc...${NC}"
  
  # Remover configurações antigas se existirem
  sed -i '' '/# Python Configuration/,/# End Python Configuration/d' "$HOME/.zshrc" 2>/dev/null
  
  cat >> "$HOME/.zshrc" << EOF
# Python Configuration
export WORKON_HOME="$PYTHON_DIR/virtualenvs"
export PIP_DOWNLOAD_CACHE="$PYTHON_DIR/pip_cache"

# Função para criar virtualenv no HD externo
mkvenv() {
  python -m venv "$PYTHON_DIR/virtualenvs/\$1"
  echo "Virtualenv criado em $PYTHON_DIR/virtualenvs/\$1"
  echo "Para ativar: source $PYTHON_DIR/virtualenvs/\$1/bin/activate"
}
# End Python Configuration
EOF

  echo -e "${GREEN}Python configurado com sucesso!${NC}"
  echo -e "${YELLOW}Para criar um ambiente virtual, execute: 'source ~/.zshrc && mkvenv nome_do_ambiente'${NC}"
}

# Função para configurar Docker
setup_docker() {
  echo -e "${GREEN}Configurando Docker para usar o HD externo...${NC}"
  
  DOCKER_DIR="$HD_PATH/dev_environment/docker"
  
  # Criar diretório para configuração do Docker
  mkdir -p "$HOME/.docker"
  
  # Criar arquivo de configuração do Docker
  cat > "$HOME/.docker/daemon.json" << EOF
{
  "data-root": "$DOCKER_DIR"
}
EOF

  echo -e "${GREEN}Docker configurado com sucesso!${NC}"
  echo -e "${YELLOW}Reinicie o Docker Desktop para aplicar as alterações.${NC}"
}

# Função para configurar VS Code
setup_vscode() {
  echo -e "${GREEN}Configurando VS Code para usar o HD externo...${NC}"
  
  VSCODE_DIR="$HD_PATH/dev_environment/vscode"
  
  # Adicionar configurações ao .zshrc
  echo -e "${YELLOW}Adicionando configurações do VS Code ao .zshrc...${NC}"
  
  # Remover configurações antigas se existirem
  sed -i '' '/# VS Code Configuration/,/# End VS Code Configuration/d' "$HOME/.zshrc" 2>/dev/null
  
  cat >> "$HOME/.zshrc" << EOF
# VS Code Configuration
export VSCODE_EXTENSIONS="$VSCODE_DIR/extensions"
# End VS Code Configuration
EOF

  echo -e "${GREEN}VS Code configurado com sucesso!${NC}"
  echo -e "${YELLOW}Você precisará reinstalar as extensões do VS Code.${NC}"
}

# Função para configurar Ollama
setup_ollama() {
  echo -e "${GREEN}Configurando Ollama no HD externo...${NC}"
  
  OLLAMA_DIR="$HD_PATH/dev_environment/ollama"
  
  # Adicionar configurações ao .zshrc
  echo -e "${YELLOW}Adicionando configurações do Ollama ao .zshrc...${NC}"
  
  # Remover configurações antigas se existirem
  sed -i '' '/# Ollama Configuration/,/# End Ollama Configuration/d' "$HOME/.zshrc" 2>/dev/null
  
  cat >> "$HOME/.zshrc" << EOF
# Ollama Configuration
export OLLAMA_HOME="$OLLAMA_DIR"
export OLLAMA_MODELS="$OLLAMA_DIR/models"

# Alias para iniciar o Ollama
alias start-ollama="$OLLAMA_DIR/start_ollama.sh"
# End Ollama Configuration
EOF

  # Criar script de inicialização do Ollama
  cat > "$OLLAMA_DIR/start_ollama.sh" << 'EOF'
#!/bin/bash
export OLLAMA_HOME="$OLLAMA_HOME"
export OLLAMA_MODELS="$OLLAMA_MODELS"
ollama serve
EOF

  chmod +x "$OLLAMA_DIR/start_ollama.sh"

  echo -e "${GREEN}Ollama configurado com sucesso!${NC}"
  echo -e "${YELLOW}Para instalar o Ollama, execute: 'curl -L https://ollama.com/download/ollama-darwin-amd64 -o $OLLAMA_DIR/ollama && chmod +x $OLLAMA_DIR/ollama'${NC}"
  echo -e "${YELLOW}Para iniciar o Ollama, execute: 'source ~/.zshrc && start-ollama'${NC}"
}

# Função para criar script de verificação do HD
create_check_script() {
  echo -e "${GREEN}Criando script de verificação do HD...${NC}"
  
  cat > "$HOME/check_hd.sh" << EOF
#!/bin/bash
if [ ! -d "$HD_PATH" ]; then
  echo -e "\033[0;31mHD externo não está montado em $HD_PATH!\033[0m"
  echo -e "\033[1;33mPor favor, conecte o HD externo para usar o ambiente de desenvolvimento.\033[0m"
  return 1
fi
EOF

  chmod +x "$HOME/check_hd.sh"
  
  # Adicionar ao .zshrc
  echo -e "${YELLOW}Adicionando verificação do HD ao .zshrc...${NC}"
  
  # Remover configurações antigas se existirem
  sed -i '' '/# HD Check/,/# End HD Check/d' "$HOME/.zshrc" 2>/dev/null
  
  cat >> "$HOME/.zshrc" << EOF
# HD Check
source "\$HOME/check_hd.sh"
# End HD Check
EOF

  echo -e "${GREEN}Script de verificação criado com sucesso!${NC}"
}

# Função principal
main() {
  echo -e "${GREEN}=== Configuração de Ambiente de Desenvolvimento no HD Externo ===${NC}"
  echo -e "${YELLOW}Este script irá configurar um ambiente de desenvolvimento completo no seu HD externo.${NC}"
  echo -e "${YELLOW}HD externo configurado em: $HD_PATH${NC}"
  echo ""
  
  # Verificar se o HD está conectado
  check_hd
  
  # Perguntar ao usuário o que ele deseja configurar
  echo "Selecione o que você deseja configurar:"
  echo "1. Configurar tudo"
  echo "2. Apenas Node.js (NVM)"
  echo "3. Apenas Homebrew"
  echo "4. Apenas Python"
  echo "5. Apenas Docker"
  echo "6. Apenas VS Code"
  echo "7. Apenas Ollama"
  echo "0. Sair"
  
  read -p "Opção: " option
  
  case $option in
    1)
      create_directories
      setup_node
      setup_homebrew
      setup_python
      setup_docker
      setup_vscode
      setup_ollama
      create_check_script
      ;;
    2)
      create_directories
      setup_node
      create_check_script
      ;;
    3)
      create_directories
      setup_homebrew
      create_check_script
      ;;
    4)
      create_directories
      setup_python
      create_check_script
      ;;
    5)
      create_directories
      setup_docker
      create_check_script
      ;;
    6)
      create_directories
      setup_vscode
      create_check_script
      ;;
    7)
      create_directories
      setup_ollama
      create_check_script
      ;;
    0)
      echo -e "${YELLOW}Saindo...${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Opção inválida!${NC}"
      exit 1
      ;;
  esac
  
  echo ""
  echo -e "${GREEN}=== Configuração concluída! ===${NC}"
  echo -e "${YELLOW}Para aplicar as alterações, execute: 'source ~/.zshrc'${NC}"
  echo -e "${YELLOW}Lembre-se de manter o HD externo conectado ao usar o ambiente de desenvolvimento.${NC}"
}

# Executar função principal
main 