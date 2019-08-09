class Category < ApplicationRecord
  has_many :category_payments, dependent: :destroy
  has_many :payments, through: :category_payments
  has_many :category_dictionaries, dependent: :destroy
  has_many :dictionaries, through: :category_dictionaries

  validates :name, presence: {message: 'absent'}
end
