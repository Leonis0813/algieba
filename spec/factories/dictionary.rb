FactoryBot.define do
  factory :dictionary do
    dictionary_id { SecureRandom.hex }
    phrase { SecureRandom.hex }
    condition { 'include' }
    categories { [build(:category)] }
  end
end
