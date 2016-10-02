json.array! @accounts do |account|
  json.(account, :id, :account_type, :date, :content, :category, :price, :created_at, :updated_at)
end
