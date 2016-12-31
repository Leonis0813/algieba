@settlement.each do |date, price|
  json.set! date, price
end
