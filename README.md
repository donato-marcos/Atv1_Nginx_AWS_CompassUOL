
## ETAPA 1 – CONFIGURAÇÃO DO AMBIENTE

### 1.1 Criar VPC e Sub-redes

1. Acesse o **AWS Console** > **VPC**.
2. Crie uma VPC com o bloco CIDR `192.168.100.0/24`.
3. Crie 2 sub-redes públicas e 2 sub-redes privadas.
   ![image](https://github.com/user-attachments/assets/39490445-7552-47a6-b3b0-4dee37c44da9)


### 1.2 Configurar o Security Group

1. Em **EC2**, vá para o **Security Groups** e escolha o security group que está associado à VPC criada.
2. Configure as regras de entrada (**inbound**) e saída (**outbound**) conforme necessário:
   ![image](https://github.com/user-attachments/assets/f4748441-dccd-42d8-a632-a10be8085171)

   ![image](https://github.com/user-attachments/assets/aadbcc20-285f-4e47-a866-d16d61b46f57)


### 1.3 Criar Instância EC2

1. No AWS Console, vá para EC2 > **Launch Instance**.
2. Selecione uma AMI baseada em Linux (**Amazon Linux 2023**).
3. Associe um par de chaves SSH (`chave01.pem`).
4. Configure a instância para usar uma sub-rede pública da VPC criada.
5. Escolha o security group previamente configurado.
   ![image](https://github.com/user-attachments/assets/3b1ed7d4-09ad-483d-8522-c4dc19836c27)


### 1.4 Acessar Instância

Acesse a instância via SSH usando o comando:

```bash
ssh -i /local/da/chave/privada/chave01.pem ec2-user@ip_publico
```

## ETAPA 2 – CONFIGURAÇÃO DO SERVIDOR WEB

### 2.1 Atualização e Instalação de Pacotes

1. Atualize o sistema e instale pacotes necessários:

```bash
sudo dnf clean all
sudo dnf makecache
sudo dnf upgrade -y
sudo dnf install vim tmux nginx
```

2. Configure o hostname e o fuso horário:

```bash
sudo hostnamectl set-hostname nginx01.aesthar.com.br
sudo timedatectl set-timezone America/Sao_Paulo
```

3. Edite o arquivo `/etc/hosts` para incluir o hostname, exemplo:
```bash
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.122.164 nginx01.aesthar.com.br nginx01
```

4. Habilite e inicie o serviço Nginx:

```bash
sudo systemctl enable --now nginx.service
```

5. Abra um navegador web na sua máquina e digite o endereço de ip público:
   http://ip_publico
   ![image](https://github.com/user-attachments/assets/3f65467c-e2b4-42d4-82e4-50fde939b6c4)


### 2.2 Configuração do Nginx

1. Crie diretórios para dois sites (`site1.com` e `site2.com`):

```bash
sudo mkdir -p /var/www/site1.com/html
sudo mkdir -p /var/www/site2.com/html
```

2. Crie arquivos `index.html` para cada site:

**/var/www/site1.com/html/index.html**
```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SITE 1</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <h1>Bem Vindo ao Site 1</h1>
    </body>
</html>
```

**/var/www/site2.com/html/index.html**
```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SITE 2</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <h1>Bem Vindo ao Site 2</h1>
    </body>
</html>
```

3. Configure as permissões:

```bash
chown -R $USER:$USER /var/www/site1.com/html
chown -R $USER:$USER /var/www/site2.com/html
chmod -R 755 /var/www
sudo restorecon -Rv /var/www/site1.com/html
sudo restorecon -Rv /var/www/site2.com/html
```

4. Crie arquivos de configuração do Nginx para cada site:

**/etc/nginx/conf.d/site1.com.conf**
```nginx
server {
    listen 80;
    server_name site1.aesthar.com.br;
    root /var/www/site1.com/html;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
```

**/etc/nginx/conf.d/site2.com.conf**
```nginx
server {
    listen 80;
    server_name site2.aesthar.com.br;
    root /var/www/site2.com/html;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
```

5. Teste a configuração do Nginx e reinicie o serviço:

```bash
sudo nginx -t
sudo systemctl restart nginx.service
```
   ![image](https://github.com/user-attachments/assets/3f004b3d-7ab6-4d36-a2fe-5ec1bad38b2e)


6. Adicione entradas no arquivo `/etc/hosts` para mapear os domínios:

```bash
192.168.122.164 site1.aesthar.com.br
192.168.122.164 site2.aesthar.com.br
```

7. Acesse os sites via navegador:
   - `http://site1.aesthar.com.br`
   - `http://site2.aesthar.com.br`
   
   ![image](https://github.com/user-attachments/assets/98a38796-917a-474a-b742-bd24b08488ce)

   Ou caso possua um domínio, poderá fazer uma configuração semelhante abaixo:
   ![image](https://github.com/user-attachments/assets/cf72c513-dbd3-4d74-a369-019ae280644f)


## ETAPA 3 – SCRIPT DE MONITORAMENTO + WEBHOOK

### 3.1 Criação de WebHook no Discord

1. No servidor do Discord, clique com o botão direito em "Server Settings" > "Integrations".
2. Crie um WebHook e copie a URL.
   ![image](https://github.com/user-attachments/assets/82a91aea-490f-4073-8cbd-e5802234d5b3)

3. Substitua a URL na variável do shell script:
   ![image](https://github.com/user-attachments/assets/ace84317-f0df-4a9b-ab27-9164f3f9ec7d)


### 3.2 Configuração do Script de Monitoramento

1. Instale o `cronie` para agendamento de tarefas:

```bash
sudo dnf install cronie -y
sudo systemctl enable --now crond.service
```

2. Copie o script de monitoramento para `/usr/local/bin` e torne-o executável:

   [SCRIPT](https://github.com/donato-marcos/Atv1_Nginx_AWS_CompassUOL/blob/main/monitoramento_v2.sh)

```bash
sudo scp -i /local/da/chave/privada/chave01.pem /local/do/shell_script.sh ec2-user@ip_publico:/home/ec2-user
sudo cp ~/shell_script.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/shell_script.sh
```

3. Edite o arquivo `/etc/crontab` para executar o script periodicamente:

```bash
* * * * * root export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && /usr/local/bin/shell_script.sh >> /var/log/shell_script.log 2>&1
```
SE o export PATH já estiver sendo usado no shell script não será necessário no crontab:

```bash
* * * * * root /usr/local/bin/shell_script.sh >> /var/log/shell_script.log 2>&1
```

4. O script verifica o status do serviço Nginx e envia notificações para o Discord via WebHook.
   ![image](https://github.com/user-attachments/assets/a6d46328-4ac0-4b1b-a1dd-1d1729674263)

---

# README - Configuração automatizada para Nginx Server (BONUS)

## Visão Geral

Este projeto Ansible automatiza a implantação e configuração de servidores Nginx, incluindo:
- Instalação e configuração do Nginx
- Implantação de sites estáticos
- Configuração de firewall e SELinux
- Monitoramento via scripts
- Configuração de cron jobs

  [README do Bonus](https://github.com/donato-marcos/Atv1_Nginx_AWS_CompassUOL/blob/main/nginx-server_rocky_amazon-linux/README.md)
