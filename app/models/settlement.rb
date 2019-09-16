class Settlement
  include ActiveModel::Model

  AGGREGATION_TYPE_CATEGORY = 'category'.freeze
  AGGREGATION_TYPE_PERIOD = 'period'.freeze
  AGGREGATION_TYPES = [
    AGGREGATION_TYPE_CATEGORY,
    AGGREGATION_TYPE_PERIOD,
  ].freeze

  INTERVAL_DAILY = 'daily'.freeze
  INTERVAL_MONTHLY = 'monthly'.freeze
  INTERVAL_YEARLY = 'yearly'.freeze
  INTERVALS = [
    INTERVAL_DAILY,
    INTERVAL_MONTHLY,
    INTERVAL_YEARLY,
  ].freeze
  FORMAT = {
    INTERVAL_DAILY => '%Y-%m-%d',
    INTERVAL_MONTHLY => '%Y-%m',
    INTERVAL_YEARLY => '%Y',
  }.freeze

  attr_accessor :aggregation_type, :interval, :payment_type

  validates :aggregation_type, presence: {message: 'absent'}
  validates :interval,
            presence: {message: 'absent'},
            if: -> { aggregation_type == AGGREGATION_TYPE_PERIOD }
  validates :payment_type,
            presence: {message: 'absent'},
            if: -> { aggregation_type == AGGREGATION_TYPE_CATEGORY }
  validates :aggregation_type,
            inclusion: {in: AGGREGATION_TYPES, message: 'invalid'},
            allow_nil: true
  validates :interval,
            inclusion: {in: INTERVALS, message: 'invalid'},
            allow_nil: true,
            if: -> { aggregation_type == AGGREGATION_TYPE_PERIOD }
  validates :payment_type,
            inclusion: {in: Payment::PAYMENT_TYPES, message: 'invalid'},
            allow_nil: true,
            if: -> { aggregation_type == AGGREGATION_TYPE_CATEGORY }

  def calculate
    return [] unless Payment.exists?

    case aggregation_type
    when AGGREGATION_TYPE_CATEGORY
      calculate_by_category
    when AGGREGATION_TYPE_PERIOD
      calculate_by_period
    end
  end

  def attributes
    {
      'aggregation_type' => aggregation_type,
      'interval' => interval,
      'payment_type' => payment_type,
    }
  end

  private

  def calculate_by_category
    category_price = Payment.joins(:categories)
                            .select('categories.name', 'price')
                            .payment_type(payment_type)
                            .group('categories.name')
                            .sum(:price)

    [].tap do |settlements|
      category_price.each do |category, price|
        settlements << {category: category, price: price}
      end
    end
  end

  def calculate_by_period
    columns = %i[date price]
    incomes = Payment.payment_type(Payment::PAYMENT_TYPE_INCOME).select(columns)
    expenses = Payment.payment_type(Payment::PAYMENT_TYPE_EXPENSE).select(columns)

    incomes = group_by_period(incomes, FORMAT[interval])
    expenses = group_by_period(expenses, FORMAT[interval])

    oldest = (incomes.keys | expenses.keys).min
    newest = (incomes.keys | expenses.keys).max
    periods = (oldest..newest).to_a
    periods = case interval
              when INTERVAL_YEARLY
                periods
              when INTERVAL_MONTHLY
                periods.select {|day| day[-2..-1].to_i.between?(1, 12) }
              when INTERVAL_DAILY
                (Date.parse(oldest)..Date.parse(newest)).to_a.map do |day|
                  day.strftime(FORMAT[INTERVAL_DAILY])
                end
              end

    [].tap do |settlements|
      periods.each do |period|
        settlements << {
          date: period,
          price: (incomes[period].to_i - expenses[period].to_i),
        }
      end
    end
  end

  def group_by_period(records, format)
    grouped_record = records.group_by do |record|
      record.date.strftime(format)
    end

    {}.tap do |settlement|
      grouped_record.each do |period, grouped_records|
        settlement.merge!(period => grouped_records.map(&:price).inject(:+))
      end
    end
  end
end
