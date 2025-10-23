# Quick Start - Deploy no Portainer

## ⚡ Guia Rápido de 5 Passos

### 1️⃣ Acesse o Portainer
```
http://seu-servidor:9000
```

### 2️⃣ Crie um Novo Stack
- Menu: **Stacks** → **Add stack**
- Nome: `cb-bambivis-crm`
- Método: **Git Repository**

### 3️⃣ Configure o Git
```
Repository URL: https://github.com/albertoruiz-filho/cb_bambivis_stack_v0
Reference: main
Compose path: docker-compose.yml
```

### 4️⃣ Adicione Variáveis de Ambiente

Clique em **Advanced mode** e cole:

```env
POSTGRES_PASSWORD=SuaSenhaSuperSegura123!
JWT_SECRET=SeuSecretJWTMuitoSecreto456!
```

### 5️⃣ Deploy!
Clique em **Deploy the stack** e aguarde! 🚀

---

## 📍 Acesse sua Aplicação

- **Frontend**: http://seu-servidor:3001
- **Backend API**: http://seu-servidor:3000

---

## 🔄 Atualização Automática (Opcional)

### No Portainer:
1. Vá no stack → **Webhooks** → **Add webhook**
2. Copie a URL gerada

### No GitHub:
1. Repositório → **Settings** → **Webhooks** → **Add webhook**
2. Cole a URL do Portainer
3. Salve

Pronto! Cada push atualiza automaticamente! 🎉

---

## 📖 Documentação Completa

- [README.md](README.md) - Visão geral e instruções completas
- [PORTAINER.md](PORTAINER.md) - Guia detalhado do Portainer

## 🆘 Problemas?

Verifique os logs no Portainer:
```
Stack → Container → Logs
```

## ✅ Checklist Pós-Deploy

- [ ] Stack deployado com sucesso
- [ ] Todos os containers em verde
- [ ] Frontend acessível na porta 3001
- [ ] Backend acessível na porta 3000
- [ ] Webhook configurado (opcional)

---

**Feito! Seu CRM está no ar! 🎊**
