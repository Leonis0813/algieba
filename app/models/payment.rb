class Payment < ActiveRecord::Base
  has_and_belongs_to_many :categories

  validates :payment_type, inclusion: {in: %w[income expense], message: 'invalid'}
  validates :date, presence: {message: 'invalid'}
  validates :price,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              message: 'invalid',
            }

  scope :payment_type, ->(payment_type) { where(payment_type: payment_type) }
  scope :date_before, ->(date) { where('date <= ?', date) }
  scope :date_after, ->(date) { where('date >= ?', date) }
  scope :content_equal, ->(content) { where(content: content) }
  scope :content_include, ->(content) { where('content REGEXP ?', ".*#{content}.*") }
  scope :category, lambda(category) {
    joins(:categories).where('categories.name' => category.split(','))
  }
  scope :price_upper, ->(price) { where('price >= ?', price) }
  scope :price_lower, ->(price) { where('price <= ?', price) }

  class << self
    def settle(interval)
      return [] unless Payment.exists?

      income_records = get_records('income')
      expense_records = get_records('expense')

      format = {'yearly' => '%Y', 'monthly' => '%Y-%m', 'daily' => '%Y-%m-%d'}

      incomes = group_by_period(income_records, format[interval])
      expenses = group_by_period(expense_records, format[interval])

      oldest = (incomes.keys | expenses.keys).min
      newest = (incomes.keys | expenses.keys).max
      periods = (oldest..newest).to_a
      periods = {
        'yearly' => periods,
        'monthly' => periods.select {|day| day[-2..-1].to_i.between?(1, 12) },
        'daily' => (Date.parse(oldest)..Date.parse(newest)).to_a.map do |day|
          day.strftime(format['daily'])
        end,
      }

      [].tap do |settlements|
        periods[interval].each do |period|
          settlements << {
            date: period,
            price: (incomes[period].to_i - expenses[period].to_i),
          }
        end
      end
    end

    private

    def get_records(payment_type)
      records = Payment.payment_type(payment_type).pluck(:date, :price)
      records.map {|date, price| {date: date, price: price} }
    end

    def group_by_period(records, format)
      {}.tap do |record|
        grouped_record = records.group_by do |record|
          record[:date].strftime(format)
        end

        grouped_record.each do |period, records|
          record.merge!(period => records.map {|record| record[:price] }.inject(:+))
        end
      end
    end
  end
end
