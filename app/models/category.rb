class Category < ApplicationRecord
  has_many :category_payments, dependent: :destroy
  has_many :payments, through: :category_payments
  has_many :category_dictionaries, dependent: :destroy
  has_many :dictionaries, through: :category_dictionaries

  validates :category_id,
            string: {format: ID_FORMAT},
            uniqueness: {message: MESSAGE_DUPLICATED}
  validates :name,
            uniqueness: {message: MESSAGE_DUPLICATED}

  scope :name_include, ->(name) { where('name REGEXP ?', ".*#{name}.*") }

  after_initialize if: :new_record? do |category|
    category.category_id = SecureRandom.hex
  end
end
