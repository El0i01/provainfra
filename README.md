# provainfra
# Desafio de Infraestrutura Cloud - Rodrigo Eloi

Este projeto implementa uma arquitetura de 3 camadas na AWS (VPC Customizada), focando em segurança, isolamento de rede e baixo custo (Free Tier), conforme solicitado na prova prática.

## 🌐 Acesso à Aplicação
* **URL Pública:** [https://prova.cyberselva.com](https://prova.cyberselva.com)
* **Health Check (JSON):** [https://prova.cyberselva.com/health](https://prova.cyberselva.com/health)

## 🏗 Arquitetura Implementada

* **VPC:** Rede customizada (`10.0.0.0/16`) com segmentação de subnets.
* **Subnet Pública:** Hospeda o Proxy Reverso (Nginx) e a Aplicação Node.js. Esta instância também atua como **NAT Gateway (via iptables)** para permitir que a rede privada baixe atualizações sem custo adicional.
* **Subnet Privada:** Hospeda o Banco de Dados (PostgreSQL), totalmente isolada da internet direta (sem IP público).
* **Segurança:** Configurada via *Security Group Chaining*. O Banco de Dados aceita conexões apenas da faixa de IP da VPC.

## 🚀 Decisões Técnicas e Justificativas

1.  **NAT Instance vs NAT Gateway:**
    * **Decisão:** Configurei a EC2 Pública para atuar como roteador NAT (masquerade).
    * **Motivo:** O *AWS NAT Gateway* gerenciado possui custo elevado para o Free Tier. Utilizar a própria EC2 pública como Gateway reduz o custo a zero, mantendo a funcionalidade de saída de internet para a rede privada (necessária para instalar o Docker).

2.  **Proxy Reverso (Nginx):**
    * Utilizado para proteger a aplicação, servindo como porta de entrada única (Porta 80) e ocultando a tecnologia do backend.

3.  **Banco de Dados Isolado:**
    * O PostgreSQL roda em Container Docker na Subnet Privada. Isso garante a segurança dos dados, impedindo acesso externo direto.

## 🛠 Resumo de Instalação

### 1. Infraestrutura de Rede
* Criação de VPC e Subnets (Pública/Privada).
* Configuração de tabelas de rotas: Pública apontando para IGW; Privada apontando para a EC2 Pública (NAT).

### 2. Banco de Dados (Camada Privada)
* Instalação do Docker na EC2 Privada.
* Execução do container PostgreSQL:
    ```bash
    docker run -d --name banco-prova -e POSTGRES_PASSWORD=infra123 -p 5432:5432 postgres:14
    ```

### 3. Aplicação e Proxy (Camada Pública)
* Instalação do Node.js e PM2.
* Configuração do Nginx (`/etc/nginx/sites-available/app`) como Proxy Reverso.
* Ajuste de Security Groups para permitir tráfego HTTP (80) global e PostgreSQL (5432) local.

## 🔐 Acesso para Validação (IAM)

Foi criado um usuário IAM dedicado para auditoria, seguindo o princípio do menor privilégio (Policy: `ReadOnlyAccess`).

* **URL de Login:** https://125394634232.signin.aws.amazon.com/console
* **Usuário:** `validador-prova`
* **Senha:** `Prova@2026`

> **Nota:** Este usuário possui permissão de leitura global para validar EC2, VPC e Logs, mas não pode alterar ou excluir recursos.

## ⭐ Diferenciais Entregues
* **Snapshots:** Backup do volume do banco de dados realizado.
* **Automação:** Script `install_automation.sh` incluído.
* **Orquestração:** Arquivo `docker-compose.yml` incluído para demonstração.