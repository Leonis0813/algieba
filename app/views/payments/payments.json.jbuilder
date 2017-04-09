json.array! @payments do |payment|
  json.(payment, :id, :payment_type, :date, :content)
  json.categories(payment.categories, :id, :name)
  json.(payment, :price, :created_at, :updated_at)
end
