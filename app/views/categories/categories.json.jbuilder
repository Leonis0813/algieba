json.array! @categories do |category|
  json.(category, :id, :name, :description)
end
