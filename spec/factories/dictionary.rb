FactoryBot.define do
  factory :dictionary do
    dictionary_id { SecureRandom.hex }
    phrase { 'test' }
    condition { 'include' }
  end
end
