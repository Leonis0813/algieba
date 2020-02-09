json.payments do
  json.array!(@payments) do |payment|
    json.(payment, :payment_id, :payment_type, :date, :content)
    json.categories(payment.categories, :category_id, :name, :description)
    json.tags(payment.tags, :tag_id, :name)
    json.(payment, :price)
  end
end
