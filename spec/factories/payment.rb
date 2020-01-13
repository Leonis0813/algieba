FactoryBot.define do
  factory :payment do
    payment_type { 'income' }
    date { '1000-01-01' }
    content { 'test' }
    categories { [FactoryBot.create(:category)] }
    tags { [FactoryBot.create(:tag)] }
    price { 1000 }
  end
end
