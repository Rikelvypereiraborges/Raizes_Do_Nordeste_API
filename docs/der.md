# DER - Modelo de Dados

## Entidades

### users

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| name | string | obrigatorio |
| email | string | obrigatorio, unico |
| password_digest | string | obrigatorio |
| role | string | `cliente`, `atendente`, `cozinha`, `gerente`, `admin` |
| consent_at | datetime | aceite de privacidade |
| last_login_at | datetime | ultimo login |

### units

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| name | string | obrigatorio |
| city | string | obrigatorio |
| state | string | UF |
| active | boolean | padrao `true` |

### products

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| name | string | obrigatorio |
| description | text | opcional |
| price_cents | integer | maior que zero |
| active | boolean | padrao `true` |

### stocks

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| unit_id | bigint | FK `units.id` |
| product_id | bigint | FK `products.id` |
| quantity | integer | maior ou igual a zero |

Restricao: uma unidade possui apenas um registro de estoque por produto.

### orders

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK `users.id` |
| unit_id | bigint | FK `units.id` |
| canal_pedido | string | `APP`, `TOTEM`, `BALCAO`, `PICKUP`, `WEB` |
| status | string | status operacional do pedido |
| total_cents | integer | maior ou igual a zero |
| cancelled_at | datetime | preenchido no cancelamento |

### order_items

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| order_id | bigint | FK `orders.id` |
| product_id | bigint | FK `products.id` |
| quantity | integer | maior que zero |
| unit_price_cents | integer | maior que zero |
| total_cents | integer | maior que zero |

### payments

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| order_id | bigint | FK `orders.id` |
| status | string | `pendente`, `aprovado`, `negado` |
| provider | string | `MOCK` |
| amount_cents | integer | maior ou igual a zero |
| request_payload | json | payload enviado |
| response_payload | json | resposta do mock |

### audit_logs

| Campo | Tipo | Regra |
| --- | --- | --- |
| id | bigint | PK |
| user_id | bigint | FK `users.id`, opcional |
| action | string | acao auditada |
| auditable_type | string | tipo do registro |
| auditable_id | bigint | id do registro |
| metadata | json | detalhes da acao |
| ip_address | string | IP da requisicao |

## Relacionamentos

- Usuario 1:N Pedido
- Unidade 1:N Pedido
- Unidade N:N Produto por meio de Estoque
- Pedido 1:N Item de Pedido
- Produto 1:N Item de Pedido
- Pedido 1:N Pagamento
- Usuario 1:N Log de Auditoria

Imagem: `docs/der.svg`.
