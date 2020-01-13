json.payments do
  json.array!(@payments) do |payment|
    json.(payment, :id, :payment_type, :date, :content)
    json.categories(payment.categories, :id, :name, :description)
    json.tags(payment.tags, :tag_id, :name)
    json.(payment, :price)
  end
end
