class PaymentQuery < Query
  MESSAGE_INVALID = ApplicationRecord::MESSAGE_INVALID
  DEFAULT_SORT = 'payment_id'.freeze
  SORT_LIST = [DEFAULT_SORT, 'date', 'price'].freeze

  attr_accessor :payment_type, :date_before, :date_after, :content_equal,
                :content_include, :category, :tag, :price_upper, :price_lower, :sort

  validates :payment_type,
            inclusion: {in: Payment::PAYMENT_TYPE_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validates :price_upper, :price_lower,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true
  validates :sort, inclusion: {in: SORT_LIST, message: MESSAGE_INVALID}

  validate :date_valid?
  validate :period_valid?

  def initialize(attributes = {})
    super
    self.sort ||= DEFAULT_SORT
  end

  def date_valid?
    return unless date_before or date_after

    [
      [:date_before, date_before],
      [:date_after, date_after],
    ].each do |date_symbol, date_value|
      Date.parse(date_value) if date_value rescue errors.add(date_symbol, MESSAGE_INVALID)
    end
  end

  def period_valid?
    if errors.messages.include?(:date_before) or errors.messages.include?(:date_after)
      return
    end

    return unless date_before and date_after

    return unless Date.parse(date_before) < Date.parse(date_after)

    errors.add(:date_before, MESSAGE_INVALID)
    errors.add(:date_after, MESSAGE_INVALID)
  end
end
