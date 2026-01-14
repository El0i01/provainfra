#!/bin/bash
# Script de Automação para Setup da EC2 Pública (App + NAT + Proxy)
# Autor: Rodrigo Eloi

echo ">>> Iniciando Setup da Infraestrutura..."

# 1. Atualiza o sistema
sudo apt update && sudo apt upgrade -y

# 2. Instala Docker, Node.js e Nginx
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y docker.io nodejs nginx git

# 3. Configura Permissões do Docker
sudo usermod -aG docker ubuntu

# 4. Configura NAT (Masquerade) - CRUCIAL PARA A REDE PRIVADA
# Habilita o repasse de IP no Kernel
sudo sysctl -w net.ipv4.ip_forward=1
# Descobre a interface de rede principal (ex: eth0 ou enX0)
INTERFACE=$(ip route | grep default | awk '{print $5}')
# Cria regra de NAT no iptables
sudo iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
echo ">>> NAT Configurado na interface $INTERFACE"

# 5. Instala PM2 para gerenciar a aplicação Node.js
sudo npm install -g pm2

# 6. Configura Proxy Reverso Nginx
cat <<EOF | sudo tee /etc/nginx/sites-available/app-prova
server {
    listen 80;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Ativa o site e reinicia o Nginx
sudo ln -sf /etc/nginx/sites-available/app-prova /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo ">>> Setup Concluído com Sucesso! 🚀"