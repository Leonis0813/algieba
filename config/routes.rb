Rails.application.routes.draw do
  scope :api, :format => 'json' do
    resources :categories, :only => [:index]
    resources :payments, :except => [:new, :edit]
    get '/settlement' => 'payments#settle'
  end

  resources :payments, :only => [:index], :format => 'html'
  get '/login' => 'login#form'
  post '/login' => 'login#authenticate_user'
end
