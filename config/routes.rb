Rails.application.routes.draw do
  

  root to: 'auth#login'
  post  'login',  to: 'auth#login_do', as: 'login'
  match 'logout', to: 'auth#logout', via: [:get, :post], as: 'logout'

  get  'app',         to: 'nexmo_app#show',    as: 'app'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
