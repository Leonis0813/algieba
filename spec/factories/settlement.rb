FactoryBot.define do
  factory :settlement do
    aggregation_type { 'category' }
    interval { 'daily' }
    payment_type { 'income' }
  end
end
