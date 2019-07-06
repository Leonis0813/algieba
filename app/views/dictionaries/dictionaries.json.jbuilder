json.dictionaries do
  json.array!(@dictionaries) do |dictionary|
    json.(dictionary, :id, :phrase, :condition)
    json.categories do
      json.array!(dictionary.categories) do |category|
        json.(category, :id, :name, :description)
      end
    end
  end
end
