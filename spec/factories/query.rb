FactoryBot.define do
  factory :query do
    page { '1' }
    per_page { '1' }
    order { 'asc' }
  end
end
