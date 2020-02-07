FactoryBot.define do
  factory :category do
    category_id { SecureRandom.hex }
    name { 'test' }
    description { nil }
    initialize_with { Category.find_or_create_by(name: name) }
  end
end
