TransactionSettlement::Application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'settle_transaction', to: "main#settle_transaction"
    end
  end
end
