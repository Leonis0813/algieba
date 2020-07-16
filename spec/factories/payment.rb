FactoryBot.define do
  factory :payment do
    payment_id { SecureRandom.hex }
    payment_type { 'income' }
    date { '1000-01-01' }
    content { 'test' }
    categories { [build(:category)] }
    tags { [build(:tag)] }
    price { 1000 }
  end
end
