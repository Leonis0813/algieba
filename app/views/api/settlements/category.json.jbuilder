json.settlements do
  json.array!(@settlements) do |settlement|
    json.(settlement, :category, :price)
  end
end
