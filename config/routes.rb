Rails.application.routes.draw do
  top = "#{Rails.application.config.relative_url_root}/management/payments"

  root to: redirect(top)

  namespace :api, format: 'json' do
    resources :categories, only: %i[index]
    resources :dictionaries, only: %i[create index]
    resources :payments, except: %i[new edit], param: :payment_id
    resources :tags, only: %i[create] do
      post 'payments' => 'tags#assign_payments', param: :tag_id
    end
    resource :settlements, only: [] do
      get 'category' => 'settlements#category'
      get 'period' => 'settlements#period'
    end
  end

  scope :management do
    get '/', to: redirect(top)
    resources :payments, only: %i[index], format: 'html'
    resources :categories, only: %i[index], format: 'html'
    resources :dictionaries, only: %i[index], format: 'html'
    resources :tags, only: %i[index], format: 'html'
  end

  resources :statistics, only: %i[index], format: 'html'
end
