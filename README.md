

# **Projeto: Configuração de Servidor Web com Nginx no Rocky Linux e Amazon Linux**

Este projeto consiste na configuração de um servidor web utilizando **Nginx** em sistemas **Rocky Linux** e **Amazon Linux**. O projeto aborda a instalação do Nginx, a configuração de múltiplos sites, a criação de scripts de monitoramento e a automação de tarefas com **Crontab**.

---

## **Etapa 1: Configuração Inicial do Servidor**

### **1.1 Atualização do Sistema**
Antes de começar, é importante atualizar o sistema e instalar ferramentas úteis:

```bash
sudo dnf clean all
sudo dnf makecache
sudo dnf upgrade -y
sudo dnf install vim tmux -y
```

### **1.2 Configuração do Hostname e Fuso Horário**
Defina o hostname e o fuso horário do servidor:

```bash
sudo hostnamectl set-hostname nginx01.aesthar.com.br
sudo timedatectl set-timezone America/Sao_Paulo
```

### **1.3 Configuração do Arquivo `/etc/hosts`**
Adicione o hostname ao arquivo `/etc/hosts`:

```bash
sudo vim /etc/hosts
```

Adicione as seguintes linhas:

```plaintext
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.122.164 nginx01.aesthar.com.br nginx01
```

---

## **Etapa 2: Instalação e Configuração do Nginx**

### **2.1 Instalação do Nginx**
Instale o Nginx e habilite o serviço para iniciar automaticamente:

```bash
sudo dnf install nginx -y
sudo systemctl enable --now nginx.service
```

### **2.2 Configuração do Firewall (Apenas para Rocky Linux)**
No Rocky Linux, libere as portas HTTP e HTTPS no firewall:

```bash
sudo firewall-cmd --permanent --add-service={http,https}
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --reload
```

### **2.3 Teste de Funcionamento do Nginx**
Abra um navegador e acesse o endereço IP do servidor:

```plaintext
http://Endereço_IP
```
![image](https://github.com/user-attachments/assets/63e0fe62-9959-4d4c-94b0-f69aa7749797)


Se o Nginx estiver funcionando corretamente, você verá a página de teste padrão.

---

## **Etapa 3: Configuração de Múltiplos Sites**

### **3.1 Criação dos Diretórios dos Sites**
Crie diretórios para dois sites diferentes:

```bash
sudo mkdir -p /var/www/site1.com/html
sudo mkdir -p /var/www/site2.com/html
```

### **3.2 Criação das Páginas HTML**
Crie páginas HTML simples para cada site:

**Site 1:**

```bash
sudo vim /var/www/site1.com/html/index.html
```

Adicione o seguinte conteúdo:

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

**Site 2:**

```bash
sudo vim /var/www/site2.com/html/index.html
```

Adicione o seguinte conteúdo:

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

### **3.3 Ajuste de Permissões**
Ajuste as permissões dos diretórios:

```bash
chown -R $USER:$USER /var/www/site1.com/html
chown -R $USER:$USER /var/www/site2.com/html
chmod -R 755 /var/www
sudo restorecon -Rv /var/www/site1.com/html
sudo restorecon -Rv /var/www/site2.com/html
```

### **3.4 Configuração dos Arquivos de Configuração do Nginx**
Crie arquivos de configuração para cada site:

**Site 1:**

```bash
sudo vim /etc/nginx/conf.d/site1.com.conf
```

Adicione o seguinte conteúdo:

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

**Site 2:**

```bash
sudo vim /etc/nginx/conf.d/site2.com.conf
```

Adicione o seguinte conteúdo:

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

### **3.5 Teste e Reinicialização do Nginx**
Teste a configuração do Nginx e reinicie o serviço:

```bash
sudo nginx -t
sudo systemctl restart nginx.service
```

---

## **Etapa 4: Automação com Shell Script e Crontab**

### **4.1 Instalação do Cronie**
Instale o **cronie** para agendar tarefas:

```bash
sudo dnf install cronie -y
sudo systemctl enable --now crond.service
```

### **4.2 Criação do Script de Monitoramento**
Copie o script de monitoramento para `/usr/local/bin` e torne-o executável:
https://github.com/donato-marcos/Atv1_Nginx_AWS_CompassUOL/blob/main/monitoramento_v2.sh

```bash
sudo cp ~/monitoramento.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitoramento.sh
```

### **4.3 Configuração do Crontab**
Edite o arquivo `/etc/crontab` para agendar a execução do script a cada minuto:

```bash
sudo vim /etc/crontab
```

Adicione a seguinte linha:

```plaintext
* * * * * root /usr/local/bin/monitoramento.sh >> /var/log/monitoramento.log 2>&1
```

---

