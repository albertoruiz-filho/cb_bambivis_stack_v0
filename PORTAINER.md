# Guia de Deploy no Portainer

Este guia fornece instruções detalhadas para fazer o deploy automático do CB Bambivis Stack no Portainer.

## 🎯 Configuração Inicial

### 1. Acessar Portainer

Acesse seu Portainer em `https://seu-portainer.com` ou `http://seu-servidor:9000`

### 2. Criar um Novo Stack

1. No menu lateral, clique em **Stacks**
2. Clique no botão **Add stack**
3. Dê um nome ao stack: `cb-bambivis-crm`

### 3. Configurar o Repositório Git

Selecione a opção **Git Repository** e preencha:

**Repository URL:**
```
https://github.com/albertoruiz-filho/cb_bambivis_stack_v0
```

**Repository reference:**
```
main
```
ou o nome da branch que você deseja usar (ex: `production`, `staging`)

**Compose path:**
```
docker-compose.yml
```

**Authentication:** 
- Se o repositório for público: deixe desmarcado
- Se for privado: marque e adicione um Personal Access Token do GitHub

### 4. Configurar Variáveis de Ambiente

Clique em **Advanced mode** e adicione as seguintes variáveis:

#### Mínimo Obrigatório:
```env
POSTGRES_PASSWORD=SuaSenhaSuperSegura123!
JWT_SECRET=SeuSecretJWTSuperSecreto456!
```

#### Configuração Completa (Recomendada):
```env
# Database
POSTGRES_DB=cb_bambivis
POSTGRES_USER=cbuser
POSTGRES_PASSWORD=SuaSenhaSuperSegura123!

# Backend
NODE_ENV=production
API_PORT=3000
JWT_SECRET=SeuSecretJWTSuperSecreto456!

# Frontend
FRONTEND_PORT=3001
REACT_APP_API_URL=http://seu-dominio.com/api

# Nginx (apenas se usar perfil production)
NGINX_PORT=80
```

### 5. Deploy

1. Revise todas as configurações
2. Clique em **Deploy the stack**
3. Aguarde o Portainer baixar a imagem e iniciar os containers

## 🔄 Atualização Automática via Webhook

### Configurar no Portainer:

1. Acesse o stack criado
2. Vá para a aba **Webhooks**
3. Clique em **Add webhook**
4. Copie a URL gerada (ex: `https://seu-portainer.com/api/webhooks/xxx`)

### Configurar no GitHub:

1. Acesse o repositório no GitHub
2. Vá em **Settings** > **Webhooks** > **Add webhook**
3. Cole a URL do webhook do Portainer
4. Content type: `application/json`
5. Events: Selecione **Just the push event**
6. Active: ✓ marcado
7. Clique em **Add webhook**

Agora, sempre que você fizer um push para a branch configurada, o Portainer irá automaticamente:
1. Baixar as últimas mudanças do repositório
2. Recriar os containers com a nova configuração
3. Fazer o deploy automático

## 🔄 Atualização Automática via Polling (Alternativa)

Se você preferir polling ao invés de webhook:

1. No stack, vá em **Stack details**
2. Role até **Automatic updates**
3. Ative **Enable automatic updates**
4. Configure o intervalo (ex: 5 minutos)
5. Salve

O Portainer irá verificar o repositório periodicamente e atualizar quando detectar mudanças.

## 🛠️ Perfis de Deploy

Este stack suporta diferentes perfis:

### Perfil Padrão (Desenvolvimento/Staging)
```bash
# No Portainer, não é necessário configurar nada
# Os serviços db, backend e frontend serão iniciados
```

### Perfil Production (com Nginx)
```bash
# No Portainer, adicione nas variáveis de ambiente:
COMPOSE_PROFILES=production
```

Isso irá iniciar também o container Nginx como proxy reverso.

## 📊 Monitoramento

### Ver Logs dos Containers:

1. No Portainer, acesse **Stacks** > **cb-bambivis-crm**
2. Clique em um container específico
3. Vá para **Logs**

### Ver Status dos Containers:

No stack, você verá todos os containers e seus status:
- 🟢 Verde: rodando normalmente
- 🔴 Vermelho: com erro
- 🟡 Amarelo: iniciando

## 🔐 Segurança

### Boas Práticas:

1. **Nunca** use senhas padrão em produção
2. **Sempre** use senhas fortes e complexas
3. **Considere** usar o Portainer Secrets para variáveis sensíveis:
   - No Portainer, vá em **Secrets**
   - Crie secrets para `POSTGRES_PASSWORD` e `JWT_SECRET`
   - Referencie no stack como `${PORTAINER_SECRET_postgres_password}`

### Usar Secrets no Portainer:

1. Vá em **Secrets** > **Add secret**
2. Nome: `postgres_password`
3. Secret: sua senha
4. No stack, use: `POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password`

## 🔧 Troubleshooting

### Container não inicia:

1. Verifique os logs no Portainer
2. Verifique se todas as variáveis obrigatórias estão configuradas
3. Verifique se as portas não estão em uso

### Erro de conexão com banco:

1. Verifique se o container `db` está rodando
2. Verifique as credenciais do banco
3. Aguarde o healthcheck do banco (pode levar alguns segundos)

### Atualização não funciona:

1. Verifique se o webhook está configurado corretamente
2. Teste o webhook manualmente no GitHub (há um botão "Test")
3. Verifique os logs do Portainer

## 📞 Suporte

Para mais informações sobre o Portainer:
- Documentação oficial: https://docs.portainer.io
- Community: https://community.portainer.io

## ✅ Checklist de Deploy

- [ ] Portainer acessível e funcionando
- [ ] Stack criado com nome `cb-bambivis-crm`
- [ ] Repositório Git configurado corretamente
- [ ] Variáveis de ambiente obrigatórias configuradas
- [ ] Stack deployado com sucesso
- [ ] Todos os containers rodando (verde)
- [ ] Aplicação acessível nas portas configuradas
- [ ] Webhook configurado (opcional, mas recomendado)
- [ ] Backup do volume do banco configurado
- [ ] Documentação lida e entendida
