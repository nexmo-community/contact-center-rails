Rails.application.routes.draw do
  

  root to: 'auth#login'
  post  'login',  to: 'auth#login_do', as: 'login'
  match 'logout', to: 'auth#logout', via: [:get, :post], as: 'logout'


  get 'app/setup',        to: 'nexmo_app#setup',        as: 'app_setup'
  post 'app/create',      to: 'nexmo_app#create',       as: 'app_create'
  get 'app/reset',        to: 'nexmo_app#reset',        as: 'app_reset'
  get  'app',             to: 'nexmo_app#show',         as: 'app'
  get  'app/edit',        to: 'nexmo_app#edit',         as: 'app_edit'
  post 'app/update',      to: 'nexmo_app#update',       as: 'app_update'
  get  'app/private_key', to: 'nexmo_app#private_key',  as: 'app_private_key'
  get  'app/public_key',  to: 'nexmo_app#public_key',   as: 'app_public_key'

  post 'app/ncco/custom',   to: 'nexmo_app#update_ncco_custom',  as: 'app_ncco_custom'
  post 'app/ncco/inbound',  to: 'nexmo_app#update_ncco_inbound',  as: 'app_ncco_inbound'
  post 'app/ncco/outbound', to: 'nexmo_app#update_ncco_outbound', as: 'app_ncco_outbound'
  post 'app/ncco/ivr',      to: 'nexmo_app#update_ncco_ivr',      as: 'app_ncco_ivr'
  post 'app/ncco/whisper',  to: 'nexmo_app#update_ncco_whisper',  as: 'app_ncco_whisper'
  post 'app/ncco/queue',    to: 'nexmo_app#update_ncco_queue',    as: 'app_ncco_queue'

  get  'numbers',                         to: 'numbers#index',    as: 'numbers'
  get  'numbers/search',                  to: 'numbers#search',   as: 'numbers_search_get'
  post 'numbers/search',                  to: 'numbers#search',   as: 'numbers_search'
  post 'numbers/buy',                     to: 'numbers#buy',      as: 'numbers_buy'
  post 'numbers/add/:country/:msisdn',    to: 'numbers#add',      as: 'numbers_add'
  post 'numbers/remove/:country/:msisdn', to: 'numbers#remove',   as: 'numbers_remove'


  resources :users, only: [:index, :new, :create, :show, :destroy] do
    member do
      post :jwt
    end
  end

  get 'events',       to: 'events#index',   as: 'events'
  get 'events/raw',   to: 'events#raw',     as: 'events_raw'


  get  'api',         to: 'api#index', as: 'api'
  post 'api/jwt',     to: 'api#jwt'
  post 'api/users',   to: 'api#users'
  post 'api/ncco',    to: 'api#ncco'
  post  'api/whisper', to: 'api#whisper'
  post  'api/queue',   to: 'api#queue_conversations'
  post  'api/queue/transfer',   to: 'api#queue_transfer'


  get  'webhooks/answer', to: 'webhooks#answer',    as: 'webhooks_answer'
  get  'webhooks/answer_queue_transfer', to: 'webhooks#answer_queue_transfer',    as: 'webhooks_answer_queue_transfer'
  post 'webhooks/event',  to: 'webhooks#event',     as: 'webhooks_event'
  post 'webhooks/dtmf',  to: 'webhooks#dtmf',     as: 'webhooks_dtmf'



  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
