class Account < ActiveRecord::Base
  validates :account_type, :date, :content, :category, :price, :presence => {:message => 'absent'}
  validates :account_type, :inclusion => {:in => %w[ income expense ], :message => 'invalid'}
  validates :date, :format => {:with => /\A\d{4}-\d{2}-\d{2}\z/, :message => 'invalid'}
  validates :price, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :message => 'invalid'}

  scope :account_type, ->(account_type) { where(:account_type => account_type) }
  scope :date_before, ->(date) { where('date <= ?', date) }
  scope :date_after, ->(date) { where('date >= ?', date) }
  scope :content_equal, ->(content) { where(:content => content) }
  scope :content_include, ->(content) { where('content LIKE ?', "%#{content}%") }
  scope :category, ->(category) { where(:category => category) }
  scope :price_upper, ->(price) { where('price >= ?', price) }
  scope :price_lower, ->(price) { where('price <= ?', price) }

  class << self
    def settle(interval)
      income_records = Account.account_type('income').pluck(:date, :price).map do |date, price|
        {:date => date, :price => price}
      end

      expense_records = Account.account_type('expense').pluck(:date, :price).map do |date, price|
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

      {}.tap do |settlements|
        (incomes.keys | expenses.keys).each do |period|
          settlements.merge!(period => (incomes[period].to_i - expenses[period].to_i))
        end
      end
    end
  end
end
