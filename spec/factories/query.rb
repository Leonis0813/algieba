FactoryBot.define do
  factory :query do
    page { 1 }
    per_page { 1 }
    sort { 'payment_id' }
  end
end
