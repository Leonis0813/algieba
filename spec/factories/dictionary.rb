FactoryBot.define do
  factory :dictionary do
    phrase { 'test' }
    condition { 'include' }
  end
end
