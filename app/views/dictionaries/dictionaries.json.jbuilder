json.dictionaries do
  json.array!(@dictionaries) do |dictionary|
    json.(dictionary, :id, :phrase, :condition)
    json.categories(dictionary.categories, :id, :name, :description)
  end
end
