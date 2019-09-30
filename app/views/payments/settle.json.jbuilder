json.settlements do
  json.array! @settlement do |settlement|
    json.(settlement, :date, :price)
  end
end
