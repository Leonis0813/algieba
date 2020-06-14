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

  validates :payment_id, :payment_type, :content, :price, :categories,
            presence: {message: MESSAGE_ABSENT}
  validates :payment_id,
            format: {with: ID_FORMAT, message: MESSAGE_INVALID},
            uniqueness: {message: MESSAGE_DUPLICATED},
            allow_nil: true
  validates :payment_type,
            inclusion: {in: PAYMENT_TYPE_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validates :date,
            presence: {message: MESSAGE_INVALID}
  validates :price,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true
  validate :array_parameters

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

  private

  def array_parameters
    category_names = self.categories.map(&:name)
    errors.add(:categories, MESSAGE_SAME_VALUE) if category_names.uniq.size != category_names.size

    tag_names = self.tags.map(&:name)
    errors.add(:tags, MESSAGE_SAME_VALUE) if tag_names.uniq.size != tag_names.size
  end
end
