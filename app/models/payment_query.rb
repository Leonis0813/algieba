class PaymentQuery < Query
  MESSAGE_INVALID = ApplicationValidator::ERROR_MESSAGE[:invalid]
  DEFAULT_SORT = 'payment_id'.freeze
  SORT_LIST = [DEFAULT_SORT, 'date', 'price'].freeze
  PRICE_FORMAT = /\A[1-9]\d*|0\z/.freeze

  attr_accessor :payment_type, :date_before, :date_after, :content_equal,
                :content_include, :category, :tag, :price_upper, :price_lower, :sort

  validates :payment_type,
            string: {enum: Payment::PAYMENT_TYPE_LIST},
            allow_nil: true
  validates :date_before, :date_after,
            date: true,
            allow_nil: true
  validates :content_equal, :content_include, :category, :tag,
            string: true,
            allow_nil: true
  validates :price_upper, :price_lower,
            string: {format: PRICE_FORMAT},
            allow_nil: true
  validates :sort,
            string: {enum: SORT_LIST}

  validate :period

  def initialize(attributes = {})
    super
    self.sort ||= DEFAULT_SORT
  end

  def period
    if errors.messages.include?(:date_before) or errors.messages.include?(:date_after)
      return
    end

    return unless date_before and date_after

    return unless Date.parse(date_before) < Date.parse(date_after)

    errors.add(:date_before, MESSAGE_INVALID)
    errors.add(:date_after, MESSAGE_INVALID)
  end
end
