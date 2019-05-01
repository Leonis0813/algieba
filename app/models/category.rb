class Category < ActiveRecord::Base
  has_many :payments, through: :category_payments
end
