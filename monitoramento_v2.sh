#!/usr/bin/env bash
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#
# ---------------------------------------------------- #
# Nome do Script: monitoramento_v2.sh
# Descrição: descrição do script
# Site:
# Escrito por: Marcos Donato
# Manutenção: Marcos Donato
# Licença:
# ---------------------------------------------------- #
# Uso:
#       $ sudo ./monitoramento_v2.sh
# ---------------------------------------------------- #
# Testado em:
#       Bash "5.2.21"
# ---------------------------------------------------- #
# Histórico: v2.0 2025-03-19, Marcos:
#             - Script inicial
#             - Comentários
#             - Comunicação com Discord
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
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/Seu/Web/Hook"  # URL do webhook do Discord
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

# Função para enviar mensagens para o Discord ()
send_discord() {
    local message=$1
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" "$DISCORD_WEBHOOK_URL"
}

# Verificação de Portas e Conectividade
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

# Verificação de Configuração de Virtual Hosts
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


#
# ---------------------------------------------------- #
# --------------------- CHECKS ----------------------- #
#
#
#
# ---------------------------------------------------- #
# ----------------------- CODE ----------------------- #
#
# Criar os arquivos de log
touch {"$ONLINE_LOG","$OFFLINE_LOG"}
chown "$USER":"$USER" "$ONLINE_LOG" "$OFFLINE_LOG"

# Verificar se os arquivos de log foram criados corretamente
if [ ! -f "$ONLINE_LOG" ] || [ ! -f "$OFFLINE_LOG" ]; then
    echo "Erro: Arquivos de log não foram criados corretamente."
    send_discord "⛔ **Erro no Script**: Arquivos de log não foram criados corretamente."
    exit 1
fi

# Verificar o status do serviço Nginx
SERVICE_STATUS=$(systemctl is-active "$SERVICE_NAME" 2>/dev/null)

# Registrar o status do serviço
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

# Executar as verificações adicionais
check_ports
check_virtual_hosts

echo "Script executado com sucesso. Verifique os logs em $LOG_DIR."
send_discord "✅ **Script Executado**: Verificação do Nginx concluída. Verifique os logs em \`$LOG_DIR\`."
#
# ---------------------------------------------------- #
# ------------------------ END ----------------------- #
