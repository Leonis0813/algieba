Rails.application.routes.draw do
  post '/accounts' => 'accounts#create'
  get '/accounts' => 'accounts#read'
  put '/accounts' => 'accounts#update'
  delete '/accounts' => 'accounts#delete'

  get '/settlement' => 'accounts#settle'

  get '/' => 'accounts#manage'
end
