# Raizes do Nordeste API

API Rails criada para o Projeto Multidisciplinar - Trilha Back-End. O projeto atende ao fluxo de pedidos da rede Raizes do Nordeste, com multicanalidade, estoque por unidade, pagamento mock, autenticacao por token e controle de permissao por perfil.

## Stack

- Ruby 4.0.2
- Rails 8.1.3 em modo API
- SQLite
- Active Record migrations
- Token assinado pelo Rails para autenticacao

## Como rodar

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

No Windows, se o comando `bin/rails` nao funcionar no terminal atual, use:

```bash
ruby bin/rails db:prepare
ruby bin/rails server
```

Nao ha variaveis obrigatorias para execucao local. O arquivo `.env.example` fica no repositorio para manter o padrao de entrega.

## Dados de acesso

O seed cria dois usuarios:

- Admin: `admin@raizes.local` / `password123`
- Cliente: `cliente@raizes.local` / `password123`

## Documentacao OpenAPI

Com o servidor rodando:

- Interface visual: `GET http://localhost:3000/`
- Health check: `GET http://localhost:3000/up`
- OpenAPI JSON: `GET http://localhost:3000/api/v1/openapi.json`
- Variaveis de ambiente: veja `.env.example`
- Plano de testes: veja `docs/test_plan.md`
- Documento da entrega: veja `docs/documentacao_projeto.md`
- DER: veja `docs/der.svg` e `docs/der.md`
- Diagramas: veja os arquivos `docs/diagrama_*.svg`

## Fluxo principal para testar

1. Login:

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "cliente@raizes.local",
  "password": "password123"
}
```

2. Criar pedido:

```http
POST /api/v1/pedidos
Authorization: Bearer TOKEN
Content-Type: application/json

{
  "unitId": 1,
  "canalPedido": "TOTEM",
  "itens": [
    { "produtoId": 1, "quantidade": 2 }
  ]
}
```

3. Pagar com mock aprovado:

```http
POST /api/v1/pedidos/1/pagamentos
Authorization: Bearer TOKEN
Content-Type: application/json

{
  "formaPagamento": "MOCK",
  "cardToken": "APROVADO"
}
```

4. Consultar por canal:

```http
GET /api/v1/pedidos?canalPedido=TOTEM
Authorization: Bearer TOKEN
```

## Endpoints implementados

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/usuarios`
- `GET /api/v1/usuarios`
- `GET /api/v1/usuarios/:id`
- `GET /api/v1/unidades`
- `GET /api/v1/unidades/:id`
- `POST /api/v1/unidades`
- `GET /api/v1/produtos`
- `GET /api/v1/produtos/:id`
- `POST /api/v1/produtos`
- `PATCH /api/v1/produtos/:id`
- `GET /api/v1/estoques`
- `POST /api/v1/estoques/movimentacoes`
- `GET /api/v1/pedidos`
- `GET /api/v1/pedidos/:id`
- `POST /api/v1/pedidos`
- `PATCH /api/v1/pedidos/:id/status`
- `POST /api/v1/pedidos/:id/cancelar`
- `POST /api/v1/pedidos/:id/pagamentos`

## LGPD e seguranca

- Senhas armazenadas com hash via `has_secure_password`.
- Token obrigatorio nos endpoints sensiveis.
- Roles: `cliente`, `atendente`, `cozinha`, `gerente`, `admin`.
- O campo `consent_at` registra aceite de privacidade do usuario.
- Logs de auditoria registram login, criacao de pedido, pagamento, movimentacao de estoque e mudanca de status.
- As respostas de usuario nao expõem `password_digest`.

## Entrega

- Documentacao tecnica em `docs/documentacao_projeto.md` e `docs/documentacao_projeto.pdf`.
- Referencia dos endpoints em `docs/api.md` e OpenAPI em `/api/v1/openapi.json`.
- Colecao Postman em `docs/raizes_api.postman_collection.json`.
- Plano de testes em `docs/test_plan.md`.
- DER, casos de uso, classes e fluxo critico em `docs`.
