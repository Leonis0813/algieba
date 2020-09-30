FactoryBot.define do
  factory :category do
    category_id { SecureRandom.hex }
    name { SecureRandom.hex }
    description { nil }
  end
end
