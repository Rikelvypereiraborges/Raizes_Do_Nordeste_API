class OpenapiDocument
  def self.build
    {
      openapi: "3.0.3",
      info: {
        title: "Raizes do Nordeste API",
        version: "1.0.0",
        description: "API para pedidos multicanal, estoque por unidade, pagamento mock, autenticacao e auditoria."
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
            summary: "Login",
            requestBody: json_body(email: "cliente@raizes.local", password: "password123"),
            responses: standard_responses("Login realizado", "Credenciais invalidas")
          }
        },
        "/auth/me": {
          get: {
            summary: "Usuario autenticado",
            security: bearer,
            responses: standard_responses("Usuario autenticado")
          }
        },
        "/usuarios": {
          post: {
            summary: "Cadastrar usuario",
            requestBody: json_body(name: "Novo Cliente", email: "novo@email.com", password: "password123", password_confirmation: "password123", acceptsPrivacy: true),
            responses: standard_responses("Usuario criado")
          },
          get: {
            summary: "Listar usuarios",
            security: bearer,
            parameters: pagination_params,
            responses: standard_responses("Usuarios")
          }
        },
        "/usuarios/{id}": {
          get: {
            summary: "Consultar usuario",
            security: bearer,
            parameters: [ path_param("id") ],
            responses: standard_responses("Usuario")
          }
        },
        "/unidades": {
          get: {
            summary: "Listar unidades",
            parameters: pagination_params,
            responses: standard_responses("Unidades")
          },
          post: {
            summary: "Criar unidade",
            security: bearer,
            requestBody: json_body(name: "Raizes Boa Viagem", city: "Recife", state: "PE", active: true),
            responses: standard_responses("Unidade criada")
          }
        },
        "/unidades/{id}": {
          get: {
            summary: "Consultar unidade",
            parameters: [ path_param("id") ],
            responses: standard_responses("Unidade")
          }
        },
        "/produtos": {
          get: {
            summary: "Listar produtos",
            parameters: [ query_param("unitId"), *pagination_params ],
            responses: standard_responses("Produtos")
          },
          post: {
            summary: "Criar produto",
            security: bearer,
            requestBody: json_body(name: "Cuscuz Bowl", description: "Cuscuz com queijo coalho.", priceCents: 1990, active: true),
            responses: standard_responses("Produto criado")
          }
        },
        "/produtos/{id}": {
          get: {
            summary: "Consultar produto",
            parameters: [ path_param("id") ],
            responses: standard_responses("Produto")
          },
          patch: {
            summary: "Atualizar produto",
            security: bearer,
            parameters: [ path_param("id") ],
            requestBody: json_body(priceCents: 2190, active: true),
            responses: standard_responses("Produto atualizado")
          }
        },
        "/estoques": {
          get: {
            summary: "Listar estoque",
            security: bearer,
            parameters: [ query_param("unitId"), query_param("productId"), *pagination_params ],
            responses: standard_responses("Estoques")
          }
        },
        "/estoques/movimentacoes": {
          post: {
            summary: "Movimentar estoque",
            security: bearer,
            requestBody: json_body(unitId: 1, productId: 1, kind: "entrada", quantity: 10),
            responses: standard_responses("Estoque atualizado")
          }
        },
        "/pedidos": {
          get: {
            summary: "Listar pedidos",
            security: bearer,
            parameters: [ query_param("canalPedido"), query_param("status"), *pagination_params ],
            responses: standard_responses("Pedidos")
          },
          post: {
            summary: "Criar pedido",
            security: bearer,
            requestBody: json_body(unitId: 1, canalPedido: "TOTEM", itens: [ { produtoId: 1, quantidade: 2 } ]),
            responses: standard_responses("Pedido criado")
          }
        },
        "/pedidos/{id}": {
          get: {
            summary: "Consultar pedido",
            security: bearer,
            parameters: [ path_param("id") ],
            responses: standard_responses("Pedido")
          }
        },
        "/pedidos/{id}/status": {
          patch: {
            summary: "Atualizar status",
            security: bearer,
            parameters: [ path_param("id") ],
            requestBody: json_body(status: "preparando"),
            responses: standard_responses("Pedido atualizado")
          }
        },
        "/pedidos/{id}/cancelar": {
          post: {
            summary: "Cancelar pedido",
            security: bearer,
            parameters: [ path_param("id") ],
            responses: standard_responses("Pedido cancelado")
          }
        },
        "/pedidos/{order_id}/pagamentos": {
          post: {
            summary: "Registrar pagamento mock",
            security: bearer,
            parameters: [ path_param("order_id") ],
            requestBody: json_body(formaPagamento: "MOCK", cardToken: "APROVADO"),
            responses: standard_responses("Pagamento registrado")
          }
        }
      }
    }
  end

  def self.bearer
    [ { bearerAuth: [] } ]
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

  def self.standard_responses(success, unauthorized = "Nao autenticado")
    {
      "200": { description: success },
      "201": { description: success },
      "401": { description: unauthorized },
      "403": { description: "Sem permissao" },
      "404": { description: "Nao encontrado" },
      "422": { description: "Erro de validacao ou regra de negocio" }
    }
  end

  def self.query_param(name)
    { name: name, in: "query", required: false, schema: { type: "string" } }
  end

  def self.pagination_params
    [
      { name: "page", in: "query", required: false, schema: { type: "integer", minimum: 1 } },
      { name: "limit", in: "query", required: false, schema: { type: "integer", minimum: 1, maximum: 100 } }
    ]
  end

  def self.path_param(name)
    { name: name, in: "path", required: true, schema: { type: "integer" } }
  end
end
