FactoryBot.define do
  factory :tag do
    tag_id { SecureRandom.hex }
    name { SecureRandom.hex(5) }
  end
end
