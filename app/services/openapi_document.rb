class OpenapiDocument
  def self.build
    {
      openapi: "3.0.3",
      info: {
        title: "Raizes do Nordeste API",
        version: "0.1.0",
        description: "API Rails para o projeto Back-End: pedidos multicanal, estoque, pagamento mock, autenticacao e LGPD."
      },
      servers: [ { url: "http://localhost:3000/api/v1" } ],
      components: {
        securitySchemes: {
          bearerAuth: { type: "http", scheme: "bearer" }
        }
      },
      paths: {
        "/auth/login": {
          post: {
            summary: "Autentica usuario e retorna token",
            requestBody: json_body(email: "admin@raizes.local", password: "password123"),
            responses: { "200": { description: "Login realizado" }, "401": { description: "Credenciais invalidas" } }
          }
        },
        "/usuarios": {
          post: {
            summary: "Cadastra cliente",
            requestBody: json_body(name: "Cliente Demo", email: "cliente@email.com", password: "password123", password_confirmation: "password123", acceptsPrivacy: true),
            responses: { "201": { description: "Usuario criado" }, "422": { description: "Dados invalidos" } }
          },
          get: {
            summary: "Lista usuarios",
            security: [ { bearerAuth: [] } ],
            responses: { "200": { description: "Usuarios" }, "403": { description: "Sem permissao" } }
          }
        },
        "/unidades": {
          get: { summary: "Lista unidades", responses: { "200": { description: "Unidades" } } },
          post: {
            summary: "Cria unidade",
            security: [ { bearerAuth: [] } ],
            requestBody: json_body(name: "Unidade Centro", city: "Curitiba", state: "PR"),
            responses: { "201": { description: "Unidade criada" } }
          }
        },
        "/produtos": {
          get: { summary: "Lista cardapio/produtos", parameters: [ query_param("unitId") ], responses: { "200": { description: "Produtos" } } },
          post: {
            summary: "Cria produto",
            security: [ { bearerAuth: [] } ],
            requestBody: json_body(name: "Baiao Burger", description: "Hamburguer regional", priceCents: 2490),
            responses: { "201": { description: "Produto criado" } }
          }
        },
        "/estoques": {
          get: {
            summary: "Consulta estoque",
            security: [ { bearerAuth: [] } ],
            parameters: [ query_param("unitId"), query_param("productId") ],
            responses: { "200": { description: "Estoques" } }
          }
        },
        "/estoques/movimentacoes": {
          post: {
            summary: "Movimenta estoque por unidade",
            security: [ { bearerAuth: [] } ],
            requestBody: json_body(unitId: 1, productId: 1, kind: "entrada", quantity: 10),
            responses: { "200": { description: "Estoque atualizado" }, "422": { description: "Movimentacao invalida" } }
          }
        },
        "/pedidos": {
          get: {
            summary: "Lista pedidos com filtros por canalPedido e status",
            security: [ { bearerAuth: [] } ],
            parameters: [ query_param("canalPedido"), query_param("status") ],
            responses: { "200": { description: "Pedidos" } }
          },
          post: {
            summary: "Cria pedido exigindo canalPedido",
            security: [ { bearerAuth: [] } ],
            requestBody: json_body(unitId: 1, canalPedido: "TOTEM", itens: [ { produtoId: 1, quantidade: 2 } ]),
            responses: { "201": { description: "Pedido criado" }, "422": { description: "Pedido invalido" } }
          }
        },
        "/pedidos/{id}/pagamentos": {
          post: {
            summary: "Executa pagamento mock e atualiza status do pedido",
            security: [ { bearerAuth: [] } ],
            parameters: [ path_param("id") ],
            requestBody: json_body(formaPagamento: "MOCK", cardToken: "APROVADO"),
            responses: { "201": { description: "Pagamento registrado" }, "422": { description: "Pagamento recusado ou status invalido" } }
          }
        },
        "/pedidos/{id}/status": {
          patch: {
            summary: "Atualiza status operacional do pedido",
            security: [ { bearerAuth: [] } ],
            parameters: [ path_param("id") ],
            requestBody: json_body(status: "preparando"),
            responses: { "200": { description: "Status atualizado" }, "403": { description: "Sem permissao" } }
          }
        }
      }
    }
  end

  def self.json_body(example)
    {
      required: true,
      content: {
        "application/json": {
          schema: { type: "object" },
          example: example
        }
      }
    }
  end

  def self.query_param(name)
    { name: name, in: "query", required: false, schema: { type: "string" } }
  end

  def self.path_param(name)
    { name: name, in: "path", required: true, schema: { type: "integer" } }
  end
end
