class Payment < ApplicationRecord
  PAYMENT_TYPE_INCOME = 'income'
  PAYMENT_TYPE_EXPENSE = 'expense'
  PAYMENT_TYPES = [
    PAYMENT_TYPE_INCOME,
    PAYMENT_TYPE_EXPENSE,
  ]

  has_many :category_payments, dependent: :destroy
  has_many :categories, through: :category_payments

  validates :payment_type, :content, :price,
            presence: {message: 'absent'}
  validates :date, presence: {message: 'invalid'}
  validates :payment_type,
            inclusion: {in: PAYMENT_TYPES, message: 'invalid'},
            allow_nil: true
  validates :price,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              message: 'invalid',
            },
            allow_nil: true

  scope :payment_type, ->(payment_type) { where(payment_type: payment_type) }
  scope :date_before, ->(date) { where('date <= ?', date) }
  scope :date_after, ->(date) { where('date >= ?', date) }
  scope :content_equal, ->(content) { where(content: content) }
  scope :content_include, ->(content) { where('content REGEXP ?', ".*#{content}.*") }
  scope :category, lambda {|category|
    joins(:categories).where('categories.name' => category.split(','))
  }
  scope :price_upper, ->(price) { where('price >= ?', price) }
  scope :price_lower, ->(price) { where('price <= ?', price) }
end
