class Category < ActiveRecord::Base
  has_many :category_payments, dependent: :destroy
  has_many :payments, through: :category_payments
end
