class Category < ApplicationRecord
  has_many :category_payments, dependent: :destroy
  has_many :payments, through: :category_payments
  has_many :category_dictionaries, dependent: :destroy
  has_many :dictionaries, through: :category_dictionaries

  validates :category_id, :name,
            presence: {message: 'absent'}
  validates :category_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'},
            allow_nil: true

  after_initialize if: :new_record? do |category|
    category.category_id = SecureRandom.hex
  end
end
