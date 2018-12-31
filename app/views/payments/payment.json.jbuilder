json.(@payment, :id, :payment_type, :date, :content)
json.categories(@payment.categories, :id, :name, :description)
json.(@payment, :price)
