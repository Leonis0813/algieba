Rails.application.routes.draw do
  resources :payments, :except => [:new, :edit], :defaults => {:format => 'json'}
  get '/settlement' => 'payments#settle', :defaults => {:format => 'json'}
  get '/' => 'payments#manage'
  get '/login' => 'login#form'
  post '/login' => 'login#authenticate_user'
end
