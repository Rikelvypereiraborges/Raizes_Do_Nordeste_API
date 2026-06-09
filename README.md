# Raizes do Nordeste API

API Rails criada para o Projeto Multidisciplinar - Trilha Back-End. O MVP tem o fluxo recomendado no roteiro: pedido multicanal, pagamento mock e atualizacao de status, com persistencia em banco.

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
- DER inicial: veja `docs/der.md`

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
- `GET /api/v1/unidades`
- `POST /api/v1/unidades`
- `GET /api/v1/produtos`
- `POST /api/v1/produtos`
- `GET /api/v1/estoques`
- `POST /api/v1/estoques/movimentacoes`
- `GET /api/v1/pedidos`
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

## Proximos itens para entrega final

- Criar colecao Postman/Insomnia com pelo menos 10 cenarios.
- Transformar o DER textual em imagem/PDF e gerar os demais diagramas exigidos.
- Completar o PDF academico em formato ABNT.
- Publicar o repositorio e garantir links publicos.
