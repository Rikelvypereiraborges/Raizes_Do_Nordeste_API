# Manual de Execucao

Este manual descreve como preparar e executar a API localmente.

## 1. Pre-requisitos

- Ruby configurado conforme `.ruby-version`: `ruby-4.0.2`.
- Bundler instalado.
- SQLite disponivel no ambiente.
- Terminal PowerShell, CMD, Git Bash ou equivalente.

## 2. Instalar dependencias

Na raiz do projeto:

```bash
bundle install
```

## 3. Preparar banco de dados

```bash
ruby bin/rails db:prepare
```

Esse comando cria o banco local, executa migrations e carrega seeds quando necessario.

Para recriar os dados iniciais:

```bash
ruby bin/rails db:seed:replant
```

## 4. Executar servidor

```bash
ruby bin/rails server
```

Endereco padrao:

```text
http://localhost:3000
```

## 5. Validar funcionamento

Health check:

```http
GET http://localhost:3000/up
```

Interface demonstrativa:

```http
GET http://localhost:3000/
```

OpenAPI JSON:

```http
GET http://localhost:3000/api/v1/openapi.json
```

## 6. Usuarios seed

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Admin | `admin@raizes.local` | `password123` |
| Cliente | `cliente@raizes.local` | `password123` |

## 7. Fluxo basico manual

### Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "cliente@raizes.local",
  "password": "password123"
}
```

Copie o campo `token` retornado e use nos proximos endpoints:

```http
Authorization: Bearer TOKEN
```

### Criar pedido

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

### Pagar pedido

```http
POST /api/v1/pedidos/1/pagamentos
Authorization: Bearer TOKEN
Content-Type: application/json

{
  "formaPagamento": "MOCK",
  "cardToken": "APROVADO"
}
```

## 8. Rodar testes

```bash
ruby bin/rails test
```

## 9. Rodar verificacoes de qualidade

Quando as dependencias estiverem instaladas:

```bash
ruby bin/rubocop
ruby bin/brakeman --quiet --no-pager
ruby bin/bundler-audit
```

Tambem existe o script:

```bash
ruby bin/ci
```

## 10. Solucao de problemas

### `bin/rails` nao executa no Windows

Use:

```bash
ruby bin/rails server
```

### Banco vazio ou dados ausentes

Execute:

```bash
ruby bin/rails db:seed:replant
```

### Token invalido

Faca login novamente. Os tokens expiram em 24 horas.

### Erro de permissao

Confira se o usuario autenticado possui role adequada. Operacoes de estoque, unidade e produto exigem `gerente` ou `admin`.
