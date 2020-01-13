FactoryBot.define do
  factory :tag do
    tag_id { SecureRandom.hex }
    name { 'test' }
    initialize_with { Tag.find_or_create_by(name: name) }
  end
end
