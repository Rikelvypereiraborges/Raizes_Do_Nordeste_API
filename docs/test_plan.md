# Plano de Testes da API

Este plano cobre os principais cenarios funcionais, de seguranca e de regra de negocio da API.

## Massa de dados

Use os dados criados por `db/seeds.rb`:

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Admin | `admin@raizes.local` | `password123` |
| Cliente | `cliente@raizes.local` | `password123` |

O seed tambem cria uma unidade e produtos com estoque inicial.

## Execucao automatizada

```bash
ruby bin/rails test
```

Testes automatizados atuais:

- Criacao de pedido com pagamento mock aprovado.
- Rejeicao de acesso sem token.
- Rejeicao de pedido com `canalPedido` invalido.

## Execucao manual

Pode ser feita por Postman, Insomnia, curl ou interface `public/index.html`.

Colecao Postman:

```text
docs/raizes_api.postman_collection.json
```

## Casos de teste

| ID | Cenario | Endpoint | Entrada | Esperado |
| --- | --- | --- | --- | --- |
| T01 | Login valido cliente | `POST /api/v1/auth/login` | `cliente@raizes.local` e senha valida | `200` com token Bearer |
| T02 | Login invalido | `POST /api/v1/auth/login` | senha incorreta | `401` com erro `credenciais_invalidas` |
| T03 | Consultar usuario autenticado | `GET /api/v1/auth/me` | token valido | `200` com dados do usuario, sem `password_digest` |
| T04 | Acesso sem token | `GET /api/v1/pedidos` | sem `Authorization` | `401` com erro `nao_autenticado` |
| T05 | Listar unidades | `GET /api/v1/unidades` | sem token | `200` com unidades cadastradas |
| T06 | Listar cardapio | `GET /api/v1/produtos` | sem token | `200` com produtos ativos |
| T07 | Criar pedido valido | `POST /api/v1/pedidos` | `canalPedido=TOTEM` e item valido | `201` com status `aguardando_pagamento` |
| T08 | Criar pedido sem canal | `POST /api/v1/pedidos` | body sem `canalPedido` | `422` com erro `pedido_invalido` |
| T09 | Criar pedido com canal invalido | `POST /api/v1/pedidos` | `canalPedido=KIOSK` | `422` com erro `pedido_invalido` |
| T10 | Pagamento mock aprovado | `POST /api/v1/pedidos/:id/pagamentos` | `cardToken=APROVADO` | `201`, pagamento `aprovado`, pedido `pago` |
| T11 | Pagamento mock negado | `POST /api/v1/pedidos/:id/pagamentos` | `cardToken=NEGADO` | `201`, pagamento `negado`, pedido `pagamento_negado` |
| T12 | Atualizar status como admin | `PATCH /api/v1/pedidos/:id/status` | token admin e `status=preparando` | `200` com pedido atualizado |
| T13 | Atualizar status como cliente | `PATCH /api/v1/pedidos/:id/status` | token cliente | `403` com erro `sem_permissao` |
| T14 | Movimentar estoque entrada | `POST /api/v1/estoques/movimentacoes` | token admin, `kind=entrada` | `200` com quantidade atualizada |
| T15 | Movimentar estoque sem permissao | `POST /api/v1/estoques/movimentacoes` | token cliente | `403` com erro `sem_permissao` |
| T16 | Saida de estoque insuficiente | `POST /api/v1/estoques/movimentacoes` | token admin e quantidade maior que saldo | `422` com erro `movimentacao_invalida` |
| T17 | Cliente acessa pedido de outro usuario | `GET /api/v1/pedidos/:id` | token de cliente diferente | `403` com erro `sem_permissao` |
| T18 | Consultar OpenAPI | `GET /api/v1/openapi.json` | sem token | `200` com documento OpenAPI |

## Criterios de aceite

- Todos os endpoints publicos devem responder sem token quando previsto.
- Endpoints protegidos devem rejeitar token ausente, invalido ou expirado.
- Regras de permissao por role devem ser respeitadas.
- Pedido valido deve baixar estoque e congelar preco dos itens.
- Pagamento mock deve atualizar corretamente o status do pedido.
- Erros devem seguir o padrao `{ "error": { "code": "...", "message": "..." } }`.
