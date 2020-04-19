json.settlements do
  json.array!(@settlements) do |settlement|
    json.(settlement, :date, :price)
  end
end
