class Payment < ActiveRecord::Base
  has_and_belongs_to_many :categories

  validates :payment_type, :inclusion => {:in => %w[ income expense ], :message => 'invalid'}
  validates :date, :presence => {:message => 'invalid'}
  validates :price, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :message => 'invalid'}

  scope :payment_type, ->(payment_type) { where(:payment_type => payment_type) }
  scope :date_before, ->(date) { where('date <= ?', date) }
  scope :date_after, ->(date) { where('date >= ?', date) }
  scope :content_equal, ->(content) { where(:content => content) }
  scope :content_include, ->(content) { where('content REGEXP ?', ".*#{content}.*") }
  scope :category, ->(category) { joins(:categories).where('categories.name' => category.split(',')) }
  scope :price_upper, ->(price) { where('price >= ?', price) }
  scope :price_lower, ->(price) { where('price <= ?', price) }

  class << self
    def settle(interval)
      return [] unless Payment.exists?
      income_records = Payment.payment_type('income').pluck(:date, :price).map do |date, price|
        {:date => date, :price => price}
      end

      expense_records = Payment.payment_type('expense').pluck(:date, :price).map do |date, price|
        {:date => date, :price => price}
      end

      format = case interval
               when 'yearly'
                 '%Y'
               when 'monthly'
                 '%Y-%m'
               when 'daily'
                 '%Y-%m-%d'
               end

      incomes = {}.tap do |income|
        grouped_income_records = income_records.group_by {|record| record[:date].strftime(format) }

        grouped_income_records.each do |period, records|
          income.merge!(period => records.map{|record| record[:price] }.inject(:+))
        end
      end

      expenses = {}.tap do |expense|
        grouped_expense_records = expense_records.group_by {|record| record[:date].strftime(format) }

        grouped_expense_records.each do |period, records|
          expense.merge!(period => records.map{|record| record[:price] }.inject(:+))
        end
      end

      oldest = (incomes.keys | expenses.keys).sort.first
      newest = (incomes.keys | expenses.keys).sort.last
      periods = case interval
                when 'yearly'
                  (oldest..newest).to_a
                when 'monthly'
                  (oldest..newest).to_a.select {|day| day[-2..-1].to_i.between?(1, 12) }
                when 'daily'
                  (Date.parse(oldest)..Date.parse(newest)).to_a.map {|day| day.strftime(format) }
                end

      [].tap do |settlements|
        periods.each do |period|
          settlements << {:date => period, :price => (incomes[period].to_i - expenses[period].to_i)}
        end
      end
    end
  end
end
