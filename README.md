# Cardápio Digital - Prática Extensionista VII e VIII

Este projeto consolida o ecossistema do nosso sistema de cardápio digital. Ele serve como base tanto para o painel administrativo na web quanto para o aplicativo mobile, ambos compartilhando o mesmo serviço backend.

## Estrutura do Projeto

O repositório está organizado em três partes principais para facilitar o trabalho em equipe:

- **backend/**: É a API central do sistema, desenvolvida em Python com FastAPI e MongoDB. Ela já gerencia usuários, produtos, adicionais e pedidos. Como é uma API RESTful, ela atende simultaneamente o site e o aplicativo de forma agnóstica.
- **web/**: O painel administrativo e a visão web do sistema, focado em gerenciar o negócio. Foi montado em React com Vite e Tailwind.
- **mobile/**: O aplicativo mobile, feito em Flutter. Os clientes navegam pelo cardápio (consumido da nossa API) e a autenticação dos clientes é feita com Firebase. Já está publicado como WebApp em https://cardapio-coracao-de-mae.web.app.

## Ambiente de Desenvolvimento

Para rodar o ecossistema completo localmente, é necessário iniciar cada frente em um terminal separado. Certifique-se também de que o MongoDB esteja rodando ou configurado corretamente caso utilizem cluster externo.

### 1. Subindo o Backend
Abra um terminal na pasta `backend` e execute:
```bash
python -m venv venv
# No Windows: venv\Scripts\activate
# No Mac/Linux: source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```
A API ficará disponível em `http://localhost:8000`. A documentação interativa com todas as rotas (Swagger) pode ser acessada em `/docs`.

### 2. Subindo o Frontend Web
Em um novo terminal, entre na pasta `web` e rode:
```bash
npm install
npm run dev
```

### 3. Subindo o App 
Na pasta `mobile`, inicie o ambiente com:
```bash
flutter pub get
flutter run
```

---
Com essa organização, a gente consegue seguir caminhos paralelos: enquanto focamos na criação das telas e lógica própria do app Flutter, a API e o painel continuam operando de forma independente e estável.
