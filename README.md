NGINX ROCKY LINUX E AMAZON LINUX

sudo dnf clean all
sudo dnf makecache
sudo dnf upgrade -y

sudo dnf install vim
sudo dnf install tmux

sudo hostnamectl hostname nginx01.aesthar.com.br
sudo timedatectl set-timezone America/Sao_Paulo

sudo vim /etc/hosts
![image](https://github.com/user-attachments/assets/dfd01e08-9855-4b85-91e2-aa17cec5a2f4)


sudo dnf install nginx
sudo systemctl enable –now nginx.service



(O TRECHO ABAIXO NÃO É NECESSÁRIO NO AMAZON LINUX, POIS AS CONFIGURAÇÕES PARA LIBERAR OU BLOQUEAR PORTA SÃO FEITAS NO SECURITY GROUP)
sudo firewall-cmd --permanent –add-service={http,https}
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd –reload









abra um navegor web e digite o endereço IP do servidor
http://Endereço_IP


sudo mkdir -p /var/www/site1.com/html
sudo mkdir -p /var/www/site2.com/html

sudo vim /var/www/site1.com/html/index.html




sudo vim /var/www/site2.com/html/index.html


chown -R $USER:$USER /var/www/site1.com/html
chown -R $USER:$USER /var/www/site2.com/html
chmod -R 755 /var/www

sudo restorecon -Rv /var/www/site1.com/html
sudo restorecon -Rv /var/www/site2.com/html

sudo vim /etc/nginx/conf.d/site1.com.conf













sudo vim /etc/nginx/conf.d/site2.com.conf












Teste se a configuração esta correta:
sudo nginx -t




sudo systemctl restart nginx.service

SHELL SCRIPT E CRONTAB

Sudo dnf install cronie -y 
(NÃO SEI PQ, MAS NÃO ESTAVA INSTALADO NO AMAZON LINUX… MESMO TENDO O ARQUIVO /ETC/CRONTAB)
sudo systemctl enable –now crond.service

copie seu script para /usr/local/bin
sudo cp ~/monitoramento.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitoramento.sh

edite o arquivo /etc/crontab e adicione a linha:
* * * * * export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && /usr/local/bin/monitoramento.sh >> /var/log/monitoramento.log 2>&1

(CASO O export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin já esteja dentro do script, então não precisa estar no /etc/crontab)
sudo vim /etc/crontab

tbm é possível criar um arquivo na pasta /etc/cron.d/monitoramento e fazer as configurações dentro dele.




