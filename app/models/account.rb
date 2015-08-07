class Account < ActiveRecord::Base
  validates :date, presence: true, format: { with: /\d{4}-\d{2}-\d{2}/ }
  validates :content, presence: true
  validates :category, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
