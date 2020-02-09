Rails.application.routes.draw do
  namespace :api, format: 'json' do
    resources :categories, only: %i[index]
    resources :dictionaries, only: %i[create index]
    resources :payments, except: %i[new edit], param: :payment_id
    resource :settlements, only: [] do
      get 'category' => 'settlements#category'
      get 'period' => 'settlements#period'
    end
  end

  resources :payments, only: %i[index], format: 'html'
  resources :statistics, only: %i[index], format: 'html'
end
