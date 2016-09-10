class Query
  include ActiveModel::Model

  attr_accessor :account_type
  attr_accessor :date_before, :date_after
  attr_accessor :content_equal, :content_include
  attr_accessor :category
  attr_accessor :price_upper, :price_lower

  validates :account_type, :inclusion => {:in => %w[ income expense ], :message => 'invalid'}, :allow_nil => true
  validates :price_upper, :price_lower, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :message => 'invalid'}, :allow_nil => true
  validate :date_valid?

  def date_valid?
    return unless date_before or date_after

    [[:date_before, date_before], [:date_after, date_after]].each do |date_symbol, date_value|
      begin
        Date.parse(date_value) if date_value
      rescue ArgumentError => e
        errors.add(date_symbol, 'invalid')
      end
    end
    return if errors.any?

    if date_before and date_after and Date.parse(date_before) > Date.parse(date_after)
      errors.add(:date_before, 'invalid')
      errors.add(:date_after, 'invalid')
    end
  end
end
