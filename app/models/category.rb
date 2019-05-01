class Category < ActiveRecord::Base
  has_many :category_payments
  has_many :payments, through: :category_payments
end
