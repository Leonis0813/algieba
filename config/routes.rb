Rails.application.routes.draw do
  namespace :api, format: 'json' do
    resources :categories, only: %i[index]
    resources :dictionaries, only: %i[create index]
    resources :payments, except: %i[new edit]
    get '/settlement' => 'payments#settle'
  end

  resources :payments, only: %i[index], format: 'html'
  get '/statistics' => 'statistics#show', format: 'html'
  get '/statistics/settlements' => 'statistics/settlements#show'
  get '/login' => 'login#form', format: 'html'
  post '/login' => 'login#authenticate_user'
end
