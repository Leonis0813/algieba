Rails.application.routes.draw do
  resources :categories, :only => [:index]
  resources :payments, :except => [:new, :edit], :defaults => {:format => 'json'}
  get '/settlement' => 'payments#settle', :defaults => {:format => 'json'}
  get '/login' => 'login#form'
  post '/login' => 'login#authenticate_user'
end
