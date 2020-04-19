class Payment < ApplicationRecord
  PAYMENT_TYPE_INCOME = 'income'.freeze
  PAYMENT_TYPE_EXPENSE = 'expense'.freeze
  PAYMENT_TYPE_LIST = [
    PAYMENT_TYPE_INCOME,
    PAYMENT_TYPE_EXPENSE,
  ].freeze

  has_many :category_payments, dependent: :destroy
  has_many :categories, through: :category_payments
  has_many :payment_tags, dependent: :destroy
  has_many :tags, through: :payment_tags

  validates :payment_id, :payment_type, :content, :price,
            presence: {message: 'absent'}
  validates :date, presence: {message: 'invalid'}
  validates :payment_id,
            format: {with: ID_FORMAT, message: 'invalid'},
            allow_nil: true
  validates :payment_type,
            inclusion: {in: PAYMENT_TYPE_LIST, message: 'invalid'},
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
  scope :tag, lambda {|tag|
    joins(:tags).where('tags.name' => tag.split(','))
  }
  scope :price_upper, ->(price) { where('price >= ?', price) }
  scope :price_lower, ->(price) { where('price <= ?', price) }

  after_initialize if: :new_record? do |payment|
    payment.payment_id = SecureRandom.hex
  end
end
