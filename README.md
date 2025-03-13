## 🍎 macOS Scripts

### Development Environment Setup (`setup_dev_env.sh`)
Sets up a complete development environment on an external HD, including:
- Node.js (NVM) and Yarn
- Homebrew
- Python
- Docker
- VS Code settings
- Ollama

### SSD Cleanup (`clean_ssd.sh`)
Safely removes development environments from SSD, including:
- Node.js and NPM packages
- Homebrew and its dependencies
- Python and virtual environments
- Docker data
- VS Code data and extensions

### System Data Optimization (`clean_system_data.sh`)
Cleans and optimizes macOS System Data:
- System caches
- Old logs
- Temporary files
- Time Machine snapshots
- Unused development data

## 🚀 How to Use

1. Clone the repository
```bash
git clone https://github.com/your-username/useful-scripts.git
```

2. Give execution permission to scripts
```bash
chmod +x mac/*.sh
```

3. Run desired script
```bash
sudo ./mac/script-name.sh
```

## ⚠️ Important

- Backup before running cleanup scripts
- Check script contents before running
- Run with sudo only when necessary
- Some scripts may need adaptations for your environment

## 📝 License

MIT

---
⌨️ with ❤️ by Marllon Ramos
