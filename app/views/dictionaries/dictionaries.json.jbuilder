json.dictionaries do
  json.array!(@dictionaries) do |dictionary|
    json.(dictionary, :dictionary_id, :phrase, :condition)
    json.categories(dictionary.categories, :category_id, :name, :description)
  end
end
