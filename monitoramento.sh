#!/usr/bin/env bash
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#
# ---------------------------------------------------- #
# Nome do Script: monitoramento.sh
# Descrição: descrição do script
# Site:
# Escrito por: Marcos Donato
# Manutenção: Marcos Donato
# Licença:  
# ---------------------------------------------------- #
# Uso:
#       $ sudo ./monitoramento.sh
# ---------------------------------------------------- #
# Testado em:
#       Bash "5.2.21"
# ---------------------------------------------------- #
# Histórico:
#       v2.0 2025-03-19, Marcos:
#             - Script inicial v1.3 (2025-03-19)
#             - Comentários
#             - Comunicação com Discord
#       v2.1 2025-03-24, Marcos:
#             - Reorganização do script
#
# ---------------------------------------------------- #
# Agradecimentos: FATEC
# 		          Prof Leandro Palha
#                 Ana Azevedo (https://gist.github.com/apfzvd/300346dae55190e022ee49a1001d26af)
#
#
#
# ---------------------------------------------------- #
# -------------------- VARIABLES --------------------- #
#
SERVICE_NAME="nginx"  # Nome do serviço a ser verificado
LOG_DIR="/var/log/nginx"  # Diretório onde os logs serão armazenados
ONLINE_LOG="$LOG_DIR/online.log"  # Arquivo de log para status ONLINE
OFFLINE_LOG="$LOG_DIR/offline.log"  # Arquivo de log para status OFFLINE
TIMESTAMP=$(date +"%F %T")  # Timestamp para registro
PAGE_URL="http://localhost" # URL da página a ser verificada
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1351555076484890708/66yq2nC_1g1lVVVcpnYb3hbSIhIJ_NY_DjBM6vrPXOi6ZHEsv6JStHodTiU4nMSNNwK_"  # URL do webhook do Discord
#
# ---------------------------------------------------- #
# -------------------- FUNCTIONS --------------------- #
#
# Função para registrar mensagens de log
log_message() {
    local status=$1
    local message=$2
    local log_file=$3

    echo "$TIMESTAMP - $SERVICE_NAME - $status - $message" >> "$log_file"
}

# Função para enviar mensagens para o Discord
send_discord() {
    local message=$1
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" "$DISCORD_WEBHOOK_URL"
}

# Função para verificar se a página está acessível
check_page_status() {
    local status_code=$(curl -o /dev/null -s -w "%{http_code}\n" "$PAGE_URL")

    echo "Verificando se a página está acessível..."

    if [ "$status_code" -eq 200 ]; then
        log_message "online" "A página esta acessível." "$ONLINE_LOG"
        send_discord "✅ **Página Status**: A página $PAGE_URL está ONLINE e respondendo corretamente."
    else
        log_message "offline" "A página NÃO está acessível." "$OFFLINE_LOG"
        send_discord "❌ **Página Status**: A página $PAGE_URL está OFFLINE ou com problemas. Código de status: $status_code."
    fi
}

# Função para verificar se o Nginx está escutando nas portas 80 e 443
check_ports() {
    echo "Verificando se o Nginx está escutando nas portas 80 (HTTP) e 443 (HTTPS)..."

    # Verifica se o Nginx está escutando na porta 80 (HTTP)
    if ss -tuln | grep -q ':80'; then
        log_message "active" "Nginx está escutando na porta 80 (HTTP)." "$ONLINE_LOG"
    else
        log_message "inactive" "Nginx NÃO está escutando na porta 80 (HTTP)." "$OFFLINE_LOG"
        send_discord "⚠️ **Nginx Porta 80**: NÃO está escutando na porta 80 (HTTP)."
    fi

    # Verifica se o Nginx está escutando na porta 443 (HTTPS)
    if ss -tuln | grep -q ':443'; then
        log_message "active" "Nginx está escutando na porta 443 (HTTPS)." "$ONLINE_LOG"
    else
        log_message "inactive" "Nginx NÃO está escutando na porta 443 (HTTPS)." "$OFFLINE_LOG"
        send_discord "⚠️ **Nginx Porta 443**: NÃO está escutando na porta 443 (HTTPS)."
    fi
}

# Função para verificar a configuração de Virtual Hosts
check_virtual_hosts() {
    echo "Verificando a configuração de Virtual Hosts (server blocks)..."

    # Testa a configuração do Nginx para verificar erros de sintaxe
    nginx_t=$(nginx -t 2>&1)

    if echo "$nginx_t" | grep -q "syntax is ok" && echo "$nginx_t" | grep -q "test is successful"; then
        log_message "active" "Configuração de Virtual Hosts (server blocks) está correta." "$ONLINE_LOG"
    else
        log_message "inactive" "Erro na configuração de Virtual Hosts (server blocks): $nginx_t" "$OFFLINE_LOG"
        send_discord "❌ **Nginx Virtual Hosts**: Erro na configuração, verifique em /etc/nginx"
    fi
}

# Função para verificar o status do serviço Nginx
check_service_status() {
    SERVICE_STATUS=$(systemctl is-active "$SERVICE_NAME" 2>/dev/null)

    if [ "$SERVICE_STATUS" == "active" ]; then
        log_message "active" "O serviço $SERVICE_NAME está ONLINE." "$ONLINE_LOG"
        send_discord "✅ **Nginx Status**: O serviço $SERVICE_NAME está ONLINE."
    else
        log_message "inactive" "O serviço $SERVICE_NAME está OFFLINE." "$OFFLINE_LOG"
        send_discord "🚨 **Nginx Status**: O serviço $SERVICE_NAME está OFFLINE."

        # Tentar reiniciar o serviço se estiver offline
        echo "Tentando reiniciar o serviço $SERVICE_NAME..."
        systemctl restart "$SERVICE_NAME"
        if [ $? -eq 0 ]; then
            log_message "active" "Serviço $SERVICE_NAME reiniciado com sucesso." "$ONLINE_LOG"
            send_discord "🔄 **Nginx Status**: Serviço $SERVICE_NAME reiniciado com sucesso."
        else
            log_message "inactive" "Falha ao reiniciar o serviço $SERVICE_NAME." "$OFFLINE_LOG"
            send_discord "⛔ **Nginx Status**: Falha ao reiniciar o serviço $SERVICE_NAME."
        fi
    fi
}

# Função para criar os arquivos de log
create_logs() {
    touch "$ONLINE_LOG" "$OFFLINE_LOG"
    chown "$USER":"$USER" "$ONLINE_LOG" "$OFFLINE_LOG"

    if [ ! -f "$ONLINE_LOG" ] || [ ! -f "$OFFLINE_LOG" ]; then
        echo "Erro: Arquivos de log não foram criados corretamente."
        send_discord "⛔ **Erro no Script**: Arquivos de log não foram criados corretamente."
        exit 1
    fi
}
#
# ---------------------------------------------------- #
# --------------------- CHECKS ----------------------- #
#
#
#
# ---------------------------------------------------- #
# ----------------------- CODE ----------------------- #
#
# Inicializa os arquivos de log
initialize_logs

# Verifica o status do serviço Nginx
check_service_status

# Executa as verificações adicionais
check_page_status
check_ports
check_virtual_hosts

echo "Script executado com sucesso. Verifique os logs em $LOG_DIR."
send_discord "✅ **Script Executado**: Verificação do Nginx concluída. Verifique os logs em \`$LOG_DIR\`."
#
# ---------------------------------------------------- #
# ------------------------ END ----------------------- #
