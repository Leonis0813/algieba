FactoryBot.define do
  factory :payment_query do
    payment_type { 'income' }
    date_before { '1000-01-01' }
    date_after { '1000-01-01' }
    content_equal { 'test' }
    content_include { 'test' }
    category { 'test' }
    price_upper { '0' }
    price_lower { '0' }
    order { 'asc' }
  end
end
