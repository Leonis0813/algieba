class Query
  include ActiveModel::Model

  attr_accessor :payment_type,
                :date_before, :date_after,
                :content_equal, :content_include,
                :category,
                :price_upper, :price_lower,
                :page, :per_page,
                :sort, :order

  validates :payment_type,
            inclusion: {in: %w[income expense], message: 'invalid'}, allow_nil: true
  validates :price_upper, :price_lower, :page, :per_page,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              message: 'invalid',
            },
            allow_nil: true
  validates :sort, inclusion: {in: %w[id date price], message: 'invalid'}
  validates :order, inclusion: {in: %w[asc desc], message: 'invalid'}
  validate :date_valid?
  validate :period_valid?

  def initialize(attributes = {})
    super
    self.page ||= 1
    self.per_page ||= 10
    self.sort ||= 'id'
    self.order ||= 'asc'
  end

  def date_valid?
    return unless date_before or date_after

    [
      [:date_before, date_before],
      [:date_after, date_after],
    ].each do |date_symbol, date_value|
      begin
        Date.parse(date_value) if date_value
      rescue ArgumentError => e
        errors.add(date_symbol, 'invalid')
      end
    end
  end

  def period_valid?
    unless date_before and date_after and Date.parse(date_before) < Date.parse(date_after)
      return
    end

    errors.add(:date_before, 'invalid')
    errors.add(:date_after, 'invalid')
  end

  def attributes
    %i[
      payment_type date_before date_after content_equal content_include category
      price_upper price_lower page per_page sort order
    ].map {|name| [name, send(name)] }.to_h
  end
end
