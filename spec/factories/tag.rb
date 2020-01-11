FactoryBot.define do
  factory :tag do
    tag_id { '0' * 32 }
    name { 'test' }
    initialize_with { Tag.find_or_create_by(name: name) }
  end
end
