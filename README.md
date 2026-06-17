# Raizes do Nordeste API

API REST desenvolvida como projeto final da trilha Back-End. O sistema simula a operacao digital da rede ficticia **Raizes do Nordeste**, permitindo cadastro de usuarios, unidades, produtos, controle de estoque, criacao de pedidos multicanal e pagamento mock.

O objetivo do projeto e demonstrar uma API organizada em camadas, com autenticacao, autorizacao por perfil, regras de negocio, auditoria, documentacao tecnica e testes automatizados.

---

## Sumario

- [Tecnologias utilizadas](#tecnologias-utilizadas)
- [Principais recursos](#principais-recursos)
- [Requisitos para executar](#requisitos-para-executar)
- [Como executar localmente](#como-executar-localmente)
- [Usuarios iniciais](#usuarios-iniciais)
- [Como testar a API](#como-testar-a-api)
- [Endpoints principais](#endpoints-principais)
- [Documentacao do projeto](#documentacao-do-projeto)
- [Seguranca e regras de acesso](#seguranca-e-regras-de-acesso)
- [Arquitetura](#arquitetura)

---

## Tecnologias utilizadas

- Ruby 4.0.2
- Ruby on Rails 8.1.3 em modo API
- SQLite
- Active Record
- BCrypt
- Puma
- Minitest
- RuboCop
- Brakeman
- Bundler Audit
- OpenAPI JSON
- Postman

---

## Principais recursos

### Autenticacao

- Login com token Bearer.
- Consulta do usuario autenticado.
- Expiracao do token em 24 horas.
- Protecao dos endpoints sensiveis.

### Usuarios

- Cadastro de novos usuarios.
- Listagem e consulta por ID.
- Senhas armazenadas com hash via BCrypt.
- Perfis de acesso: `cliente`, `atendente`, `cozinha`, `gerente` e `admin`.

### Unidades

- Cadastro de unidades da rede.
- Listagem de unidades.
- Consulta individual por ID.

### Produtos

- Cadastro de produtos.
- Listagem de produtos ativos.
- Consulta individual por ID.
- Atualizacao de produto.
- Filtro de produtos com estoque por unidade.

### Estoque

- Consulta de estoque por unidade e produto.
- Movimentacao de entrada.
- Movimentacao de saida.
- Validacao de saldo disponivel.

### Pedidos

- Criacao de pedido com multiplos itens.
- Calculo automatico do valor total.
- Baixa automatica do estoque ao criar pedido.
- Filtro por canal de pedido e status.
- Atualizacao de status operacional.
- Cancelamento conforme regra de negocio.

### Pagamentos

- Pagamento mock para simular integracao com provedor externo.
- Aprovacao usando `cardToken` igual a `APROVADO`.
- Negacao usando `cardToken` igual a `NEGADO`.
- Atualizacao automatica do status do pedido.

---

## Fluxo principal do sistema

```text
Usuario
   |
Login
   |
Recebe token Bearer
   |
Consulta unidades, produtos e estoque
   |
Cria pedido
   |
API calcula total e baixa estoque
   |
Executa pagamento mock
   |
Pedido fica pago ou com pagamento negado
```

---

## Requisitos para executar

Antes de iniciar, confirme se o ambiente possui:

- Ruby conforme `.ruby-version`: `ruby-4.0.2`.
- Bundler instalado.
- SQLite disponivel no sistema.
- Git instalado.
- Terminal PowerShell, CMD, Git Bash ou equivalente.

Nao ha variaveis de ambiente obrigatorias para execucao local. O arquivo `.env.example` existe apenas para manter o padrao de entrega.

---

## Como executar localmente

### 1. Clonar o repositorio

```bash
git clone <url-do-repositorio>
```

### 2. Entrar na pasta do projeto

```bash
cd raizes_api
```

### 3. Instalar dependencias

```bash
bundle install
```

### 4. Preparar o banco de dados

```bash
ruby bin/rails db:prepare
```

Esse comando cria o banco local, executa as migrations e carrega os seeds quando necessario.

Se quiser recriar os dados iniciais do zero:

```bash
ruby bin/rails db:seed:replant
```

### 5. Subir o servidor

```bash
rails server
```

A API ficara disponivel em:

```text
http://localhost:3000
```

### 6. Validar se esta funcionando

Abra no navegador ou em uma ferramenta HTTP:

```http
GET http://localhost:3000/up
```

Se o servidor estiver correto, o health check retornara sucesso.

Tambem existe uma interface demonstrativa em:

```text
http://localhost:3000/
```

## Usuarios iniciais

O seed cria dois usuarios para facilitar os testes:

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Admin | `admin@raizes.local` | `password123` |
| Cliente | `cliente@raizes.local` | `password123` |

Use o usuario cliente para testar o fluxo de compra. Use o usuario admin para testar operacoes administrativas, como produtos, unidades e estoque.

---

## Como testar a API

### Base URL local

```text
http://localhost:3000/api/v1
```

### 1. Fazer login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "cliente@raizes.local",
  "password": "password123"
}
```

A resposta retorna um token. Use esse valor nos proximos endpoints:

```http
Authorization: Bearer TOKEN
```

### 2. Criar pedido

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

### 3. Pagar pedido

```http
POST /api/v1/pedidos/1/pagamentos
Authorization: Bearer TOKEN
Content-Type: application/json

{
  "formaPagamento": "MOCK",
  "cardToken": "APROVADO"
}
```

### 4. Consultar pedidos

```http
GET /api/v1/pedidos
Authorization: Bearer TOKEN
```

Tambem e possivel filtrar por canal:

```http
GET /api/v1/pedidos?canalPedido=TOTEM
Authorization: Bearer TOKEN
```

### Collection Postman

A collection usada nos testes esta em:

```text
docs/raizes_api.postman_collection.json
```

---

## Testes automatizados

Para executar a suite de testes:

```bash
rails test
```

Para executar verificacoes de qualidade e seguranca:

```bash
rubocop
brakeman --quiet --no-pager
bundler-audit
```

Tambem existe um script para rodar as verificacoes principais:

```bash
ci
```

---

## Endpoints principais

### Auth

- POST `/api/v1/auth/login`
- GET `/api/v1/auth/me`

### Usuarios

- POST `/api/v1/usuarios`
- GET `/api/v1/usuarios`
- GET `/api/v1/usuarios/:id`

### Unidades

- GET `/api/v1/unidades`
- GET `/api/v1/unidades/:id`
- POST `/api/v1/unidades`

### Produtos

- GET `/api/v1/produtos`
- GET `/api/v1/produtos/:id`
- POST `/api/v1/produtos`
- PATCH `/api/v1/produtos/:id`

### Estoques

- GET `/api/v1/estoques`
- POST `/api/v1/estoques/movimentacoes`

### Pedidos

- GET `/api/v1/pedidos`
- GET `/api/v1/pedidos/:id`
- POST `/api/v1/pedidos`
- PATCH `/api/v1/pedidos/:id/status`
- POST `/api/v1/pedidos/:id/cancelar`

### Pagamentos

- POST `/api/v1/pedidos/:id/pagamentos`

---

## Padrao de erros

As respostas de erro seguem o formato:

```json
{
  "error": {
    "code": "codigo_do_erro",
    "message": "Mensagem do erro."
  }
}
```

Codigos comuns:

- `credenciais_invalidas`
- `nao_autenticado`
- `sem_permissao`
- `nao_encontrado`
- `validacao`
- `pedido_invalido`
- `status_invalido`
- `pedido_nao_cancelavel`
- `movimentacao_invalida`

---

## Documentacao do projeto

Arquivos importantes para entender e validar a entrega:

- `docs/api.md`: referencia detalhada dos endpoints.
- `docs/manual_execucao.md`: passo a passo de instalacao e execucao.
- `docs/test_plan.md`: plano de testes funcional.
- `docs/documentacao_projeto.md`: documentacao tecnica completa.
- `docs/raizes_api.postman_collection.json`: collection Postman.
- `docs/der.md` e `docs/der.svg`: modelo de dados.
- `docs/diagrama_arquitetura.svg`: visao de arquitetura.
- `docs/diagrama_casos_uso.svg`: atores e casos de uso.
- `docs/diagrama_classes.svg`: classes de dominio.
- `docs/diagrama_fluxo_pedido.svg`: fluxo de pedido e pagamento.

Com o servidor rodando, a especificacao OpenAPI em JSON fica disponivel em:

```text
http://localhost:3000/api/v1/openapi.json
```

---

## Seguranca e regras de acesso

- Endpoints publicos: login, cadastro de usuario, listagem/consulta de unidades e produtos.
- Endpoints autenticados: pedidos, estoque, dados do usuario autenticado e operacoes protegidas.
- Clientes visualizam apenas os proprios pedidos.
- Operacoes administrativas exigem perfil adequado, como `gerente` ou `admin`.
- Atualizacao de status operacional aceita perfis internos, como `atendente`, `cozinha`, `gerente` ou `admin`.
- Senhas nao sao retornadas nas respostas da API.
- Logs de auditoria registram eventos importantes do sistema.

---

## Arquitetura

O projeto segue uma organizacao em camadas:

- `app/controllers`: entrada HTTP e controle das respostas.
- `app/models`: entidades, validacoes e relacionamentos.
- `app/services`: regras de negocio de pedidos, pagamentos e estoque.
- `app/controllers/concerns`: serializacao JSON.
- `config/routes.rb`: rotas versionadas em `/api/v1`.
- `db/migrate` e `db/schema.rb`: estrutura do banco de dados.
- `test`: testes automatizados.

Essa estrutura separa responsabilidades e facilita manutencao, testes e evolucao da API.

---

## Autor

Rikelvy Borges
