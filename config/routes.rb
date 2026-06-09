Rails.application.routes.draw do
  root to: redirect("/index.html")

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      get "auth/me", to: "auth#me"
      get "openapi.json", to: "openapi#show"

      resources :users, path: "usuarios", only: [ :index, :show, :create ]
      resources :units, path: "unidades", only: [ :index, :show, :create ]
      resources :products, path: "produtos", only: [ :index, :show, :create ]
      patch "produtos/:id", to: "products#update"

      resources :stocks, path: "estoques", only: [ :index ] do
        collection do
          post "movimentacoes", to: "stocks#move"
        end
      end

      resources :orders, path: "pedidos", only: [ :index, :show, :create ] do
        member do
          patch "status", to: "orders#update_status"
          post "cancelar", to: "orders#cancel"
        end

        resources :payments, path: "pagamentos", only: [ :create ]
      end
    end
  end
end
