json.array! @payments do |payment|
  json.(payment, :id, :payment_type, :date, :content, :category, :price, :created_at, :updated_at)
end
