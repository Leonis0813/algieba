Rails.application.routes.draw do
  resources :accounts, :except => [:new, :edit]
  get '/' => 'accounts#manage'
end
