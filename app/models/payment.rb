class Payment < ApplicationRecord
  PAYMENT_TYPE_INCOME = 'income'.freeze
  PAYMENT_TYPE_EXPENSE = 'expense'.freeze
  PAYMENT_TYPE_LIST = [
    PAYMENT_TYPE_INCOME,
    PAYMENT_TYPE_EXPENSE,
  ].freeze

  has_many :category_payments, dependent: :destroy
  has_many :categories, through: :category_payments, validate: false
  has_many :payment_tags, dependent: :destroy
  has_many :tags, through: :payment_tags, validate: false

  validates :payment_id,
            string: {format: ID_FORMAT},
            uniqueness: {message: MESSAGE_DUPLICATED}
  validates :categories,
            associated: {message: ApplicationValidator::ERROR_MESSAGE[:invalid]}
  validates :tags,
            associated: {message: ApplicationValidator::ERROR_MESSAGE[:invalid]},
            allow_blank: true

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
