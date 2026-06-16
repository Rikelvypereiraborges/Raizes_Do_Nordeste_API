# Referencia da API

Base local:

```text
http://localhost:3000/api/v1
```

Formato padrao:

- Entrada: JSON.
- Saida: JSON.
- Autenticacao: `Authorization: Bearer TOKEN`.
- Listagens aceitam `page` e `limit`. O retorno inclui `meta.page`, `meta.limit` e `meta.total`.

## Padrao de erro

```json
{
  "error": {
    "code": "codigo_do_erro",
    "message": "Mensagem do erro."
  }
}
```

## Autenticação

### `POST /auth/login`

Autentica usuario e retorna token valido por 24 horas.

Permissao: publico.

Body:

```json
{
  "email": "cliente@raizes.local",
  "password": "password123"
}
```

Resposta `200`:

```json
{
  "token": "TOKEN",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "user": {
    "id": 1,
    "name": "Cliente Demo",
    "email": "cliente@raizes.local",
    "role": "cliente"
  }
}
```

### `GET /auth/me`

Retorna o usuario autenticado.

Permissão: autenticado.

## Usuarios

### `POST /usuarios`

Cadastra um novo usuario.

Permissão: publico.

Body:

```json
{
  "name": "Novo Cliente",
  "email": "novo.cliente@email.com",
  "password": "password123",
  "password_confirmation": "password123",
  "acceptsPrivacy": true
}
```

### `GET /usuarios`

Lista usuarios.

Permissão: `gerente` ou `admin`.

Query params:

- `page`: pagina, padrao `1`.
- `limit`: itens por pagina, padrao `20`, maximo `100`.

### `GET /usuarios/:id`

Consulta usuario por ID.

Permissao: proprio usuario, `gerente` ou `admin`.

## Unidades

### `GET /unidades`

Lista unidades.

Permissao: publico.

Query params:

- `page`: pagina, padrao `1`.
- `limit`: itens por pagina, padrao `20`, maximo `100`.

### `GET /unidades/:id`

Consulta unidade por ID.

Permissao: publico.

### `POST /unidades`

Cria unidade.

Permissao: `gerente` ou `admin`.

Body:

```json
{
  "name": "Raizes Boa Viagem",
  "city": "Recife",
  "state": "PE",
  "active": true
}
```

## Produtos

### `GET /produtos`

Lista produtos ativos.

Permissao: publico.

Query params:

- `unitId`: filtra produtos com estoque em uma unidade.
- `page`: pagina, padrao `1`.
- `limit`: itens por pagina, padrao `20`, maximo `100`.

### `GET /produtos/:id`

Consulta produto por ID.

Permissao: publico.

### `POST /produtos`

Cria produto.

Permissao: `gerente` ou `admin`.

Body:

```json
{
  "name": "Cuscuz Bowl",
  "description": "Cuscuz com queijo coalho e carne de sol.",
  "priceCents": 1990,
  "active": true
}
```

### `PATCH /produtos/:id`

Atualiza produto.

Permissao: `gerente` ou `admin`.

Body:

```json
{
  "priceCents": 2190,
  "active": true
}
```

## Estoques

### `GET /estoques`

Lista estoques.

Permissao: autenticado.

Query params:

- `unitId`: filtra por unidade.
- `productId`: filtra por produto.
- `page`: pagina, padrao `1`.
- `limit`: itens por pagina, padrao `20`, maximo `100`.

### `POST /estoques/movimentacoes`

Movimenta estoque.

Permissao: `gerente` ou `admin`.

Body para entrada:

```json
{
  "unitId": 1,
  "productId": 1,
  "kind": "entrada",
  "quantity": 10
}
```

Body para saida:

```json
{
  "unitId": 1,
  "productId": 1,
  "kind": "saida",
  "quantity": 3
}
```

## Pedidos

### `GET /pedidos`

Lista pedidos.

Permissao: autenticado. Clientes visualizam apenas os proprios pedidos.

Query params:

- `canalPedido`: `APP`, `TOTEM`, `BALCAO`, `PICKUP` ou `WEB`.
- `status`: status atual do pedido.
- `page`: pagina, padrao `1`.
- `limit`: itens por pagina, padrao `20`, maximo `100`.

### `GET /pedidos/:id`

Consulta pedido por ID.

Permissao: autenticado. Cliente so acessa o proprio pedido.

### `POST /pedidos`

Cria pedido e baixa estoque.

Permissao: autenticado.

Body:

```json
{
  "unitId": 1,
  "canalPedido": "TOTEM",
  "itens": [
    { "produtoId": 1, "quantidade": 2 },
    { "produtoId": 2, "quantidade": 1 }
  ]
}
```

Resposta `201`:

```json
{
  "data": {
    "id": 1,
    "canalPedido": "TOTEM",
    "status": "aguardando_pagamento",
    "totalCents": 6970,
    "itens": []
  }
}
```

### `PATCH /pedidos/:id/status`

Atualiza status operacional.

Permissao: `atendente`, `cozinha`, `gerente` ou `admin`.

Body:

```json
{
  "status": "preparando"
}
```

Status aceitos:

- `aguardando_pagamento`
- `pago`
- `preparando`
- `pronto`
- `entregue`
- `cancelado`
- `pagamento_negado`

### `POST /pedidos/:id/cancelar`

Cancela pedido.

Permissao: cliente dono do pedido ou perfil interno autenticado.

Regra: permitido apenas para pedidos em `aguardando_pagamento`, `pago` ou `preparando`.

## Pagamentos

### `POST /pedidos/:order_id/pagamentos`

Executa pagamento mock.

Permissao: cliente dono do pedido, `atendente`, `gerente` ou `admin`.

Pagamento aprovado:

```json
{
  "formaPagamento": "MOCK",
  "cardToken": "APROVADO"
}
```

Pagamento negado:

```json
{
  "formaPagamento": "MOCK",
  "cardToken": "NEGADO"
}
```

Resposta aprovada:

```json
{
  "data": {
    "status": "aprovado",
    "provider": "MOCK"
  },
  "order": {
    "status": "pago"
  }
}
```

## Codigos de erro comuns

| Codigo | Quando ocorre |
| --- | --- |
| `credenciais_invalidas` | Login com e-mail ou senha invalidos |
| `nao_autenticado` | Token ausente, invalido ou expirado |
| `sem_permissao` | Usuario sem role necessaria |
| `nao_encontrado` | Registro inexistente |
| `validacao` | Erro de validacao de model |
| `pedido_invalido` | Erro de regra ao criar pedido |
| `status_invalido` | Status nao permitido ou pedido em status inadequado |
| `pedido_nao_cancelavel` | Tentativa de cancelar pedido em status nao permitido |
| `movimentacao_invalida` | Erro de regra na movimentacao de estoque |
