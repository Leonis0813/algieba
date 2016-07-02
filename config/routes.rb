Rails.application.routes.draw do
  resources :accounts, :except => [:new, :edit]
  get '/settlement' => 'accounts#settle'
  get '/' => 'accounts#manage'
end
