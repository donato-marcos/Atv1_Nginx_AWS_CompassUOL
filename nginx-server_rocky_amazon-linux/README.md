# README - Configuração automatizada para Nginx Server (BONUS)

## Visão Geral

Este projeto Ansible automatiza a implantação e configuração de servidores Nginx, incluindo:
- Instalação e configuração do Nginx
- Implantação de sites estáticos
- Configuração de firewall e SELinux
- Monitoramento via scripts
- Configuração de cron jobs

## Estrutura do Projeto

```
nginx-server/
├── ansible.cfg                     # Configurações do Ansible
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml                 # Variáveis globais
│   │   └── web_nginx_service.yml   # Variáveis específicas do Nginx
│   ├── host_vars/
│   │   ├── web_nginx_host1.yml     # Variáveis por host
│   │   └── web_nginx_host2.yml
│   ├── production                  # Inventário de produção
│   ├── staging                     # Inventário de staging
│   └── testing                     # Inventário de teste
├── playbooks/
│   ├── all.yml                     # Playbook para todos os hosts
│   └── web_nginx.yml               # Playbook específico para Nginx
├── roles/
│   ├── common/                     # Role com configurações comuns
│   └── web_nginx/                  # Role específica para Nginx
│       ├── files/                    # Arquivos estáticos
│       │   ├── atv1_web/               # Site 1
│       │   ├── site1/                  # Site 2
│       │   └── site2/                  # Site 3
│       ├── tasks/                    # Tarefas de configuração
│       │   ├── main.yml                # Arquivo principal de tasks
│       │   ├── cron.yml                # Configurações de cron jobs
│       │   ├── nginx.yml               # Instalação Nginx
│       │   ├── firewall.yml            # Configuração de firewall
│       │   └── selinux.yml             # Configuração SELinux
│       └── templates/                # Templates Jinja2
│           └── site.conf.j2            # Template de configuração do Nginx
└── vars/                           # Variáveis globais adicionais
    └── main.yml
```

## Pré-requisitos

- Ansible 2.9+
- Python 3.6+
- Acesso SSH aos servidores alvo
- Privilégios de sudo nos servidores alvo

## Como Usar

1. **Configurar inventário:**
   Edite os arquivos em `inventory/` para refletir seus ambientes:
   - `production` - Servidores de produção
   - `staging` - Servidores de staging
   - `testing` - Servidores de teste

2. **Configurar variáveis:**
   - Variáveis globais: `inventory/group_vars/all.yml`
   - Variáveis específicas do Nginx: `inventory/group_vars/web_nginx_service.yml`
   - Variáveis por host: `inventory/host_vars/*.yml`

3. **Executar playbooks:**
   ```bash
   # Para todos os hosts
   ansible-playbook -i inventory/production playbooks/all.yml

   # Apenas para servidores Nginx
   ansible-playbook -i inventory/production playbooks/web_nginx.yml
   ```

## Configurações Personalizáveis

### Arquivos Principais para Modificação

1. **Configurações do Nginx:**
   - `roles/web_nginx/templates/site.conf.j2` - Template de configuração do Nginx
   - `roles/web_nginx/files/` - Conteúdo dos sites estáticos

2. **Variáveis:**
   - `inventory/group_vars/web_nginx_service.yml` - Portas, nomes de sites, etc.
   - `inventory/host_vars/*.yml` - Configurações específicas por host

3. **Tarefas:**
   - `roles/web_nginx/tasks/` - Contém os arquivos YAML com as tarefas de:
     - Instalação do Nginx (`nginx.yml`)
     - Firewall (`firewall.yml`)
     - SELinux (`selinux.yml`)
     - Cron jobs (`cron.yml`)

## Conteúdo dos Sites

Os sites estáticos estão localizados em:
- `roles/web_nginx/files/atv1_web/` - Site 1
- `roles/web_nginx/files/site1/` - Site 2
- `roles/web_nginx/files/site2/` - Site 3

Cada diretório contém:
- `index.html` - Página principal
- `styles.css` - Folha de estilos (quando aplicável)

## Monitoramento

O script de monitoramento está localizado em:
`roles/web_nginx/files/monitoramento_v2.1.sh`

## Configuração Automatizada

O projeto inclui configuração automática de:
- Firewall (portas 80 e 443 abertas)
- SELinux (configuração para permitir o Nginx)
- Cron jobs (para tarefas de manutenção)

