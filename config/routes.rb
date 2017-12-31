Rails.application.routes.draw do
  namespace :api, :format => 'json' do
    resources :categories, :only => [:index]
    resources :payments, :except => [:new, :edit]
    get '/settlement' => 'payments#settle'
  end

  resources :payments, :only => [:index], :format => 'html'
  get '/login' => 'login#form', :format => 'html'
  post '/login' => 'login#authenticate_user'
end
