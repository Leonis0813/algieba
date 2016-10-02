Rails.application.routes.draw do
  resources :accounts, :except => [:new, :edit], :defaults => {:format => 'json'}
  get '/settlement' => 'accounts#settle', :defaults => {:format => 'json'}
  get '/' => 'accounts#manage'
end
