require "test_helper"

class OrderFlowTest < ActionDispatch::IntegrationTest
  setup do
    host! "localhost"

    @user = User.create!(
      name: "Cliente Teste",
      email: "cliente.teste@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "cliente",
      consent_at: Time.current
    )
    @unit = Unit.create!(name: "Unidade Teste", city: "Recife", state: "PE")
    @product = Product.create!(name: "Produto Teste", description: "Item de teste", price_cents: 1000)
    Stock.create!(unit: @unit, product: @product, quantity: 5)
  end

  test "creates order and approves mock payment" do
    post "/api/v1/auth/login", params: { email: @user.email, password: "password123" }, as: :json
    assert_response :success
    token = response.parsed_body.fetch("token")

    post "/api/v1/pedidos",
      params: { unitId: @unit.id, canalPedido: "TOTEM", itens: [ { produtoId: @product.id, quantidade: 2 } ] },
      headers: auth_header(token),
      as: :json

    assert_response :created
    order_id = response.parsed_body.dig("data", "id")
    assert_equal "aguardando_pagamento", response.parsed_body.dig("data", "status")
    assert_equal "TOTEM", response.parsed_body.dig("data", "canalPedido")

    post "/api/v1/pedidos/#{order_id}/pagamentos",
      params: { formaPagamento: "MOCK", cardToken: "APROVADO" },
      headers: auth_header(token),
      as: :json

    assert_response :created
    assert_equal "aprovado", response.parsed_body.dig("data", "status")
    assert_equal "pago", response.parsed_body.dig("order", "status")
  end

  test "rejects request without token" do
    get "/api/v1/pedidos", as: :json

    assert_response :unauthorized
    assert_equal "nao_autenticado", response.parsed_body.dig("error", "code")
  end

  test "rejects invalid canal pedido" do
    token = token_for(@user)

    post "/api/v1/pedidos",
      params: { unitId: @unit.id, canalPedido: "KIOSK", itens: [ { produtoId: @product.id, quantidade: 1 } ] },
      headers: auth_header(token),
      as: :json

    assert_response :unprocessable_entity
    assert_equal "pedido_invalido", response.parsed_body.dig("error", "code")
  end

  private

  def token_for(user)
    Rails.application.message_verifier(:auth_token).generate({
      "user_id" => user.id,
      "exp" => 1.hour.from_now.to_i
    })
  end

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
