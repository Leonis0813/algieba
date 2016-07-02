require 'date'

class Account < ActiveRecord::Base
  validates :account_type, :presence => true, :format => { :with => /\A(income|expense)\z/ }
  validates :date, :presence => true, :format => { :with => /\A\d{4}\-\d{2}\-\d{2}\z/ }
  validates :content, :presence => true
  validates :category, :presence => true
  validates :price, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  scope :account_type, ->(account_type) { where(:account_type => account_type) }
  scope :date_before, ->(date) { where('date <= ?', date) }
  scope :date_after, ->(date) { where('date >= ?', date) }
  scope :content_equal, ->(content) { where(:content => content) }
  scope :content_include, ->(content) { where('content LIKE %?%', content) }
  scope :category, ->(category) { where(:category => category) }
  scope :price_upper, ->(price) { where('price >= ?', price) }
  scope :price_lower, ->(price) { where('price <= ?', price) }

  class << self
    def index(condition = {})
      check_condition(condition)
      permitted_parameters_for_index.inject(Account.all) do |accounts, query|
        condition[query] ? accounts.send(query, condition[query]) : accounts
      end
    end

    def settle(interval)
      income_records = Account.where(:account_type => 'income').pluck(:date, :price).map do |record|
        {:date => record.first, :price => record.last}
      end
      expense_records = Account.where(:account_type => 'expense').pluck(:date, :price).map do |record|
        {:date => record.first, :price => record.last}
      end

      format = case interval
               when 'yearly'
                 '%Y'
               when 'monthly'
                 '%Y-%m'
               when 'daily'
                 '%Y-%m-%d'
               when nil
                 raise ArgumentError, 'absent'
               else
                 raise ArgumentError, 'invalid'
               end

      grouped_income_records = income_records.group_by do |record|
        record[:date].strftime(format)
      end
      grouped_expense_records = expense_records.group_by do |record|
        record[:date].strftime(format)
      end
    
      incomes = {}
      expenses = {}
      grouped_income_records.each do |period, records|
        prices = records.map{|record| record[:price] }
        incomes.merge!({period => prices.inject(0){|sum, price| sum + price }})
      end
      grouped_expense_records.each do |period, records|
        prices = records.map{|record| record[:price] }
        expenses.merge!({period => prices.inject(0){|sum, price| sum + price }})
      end

      periods = incomes.keys | expenses.keys
      settlements = {}
      periods.each do |period|
        settlements.merge!({period => (incomes[period] || 0) - (expenses[period] || 0)})
      end
      settlements
    end

    private

    def permitted_parameters_for_index
      %i[ account_type date_before date_after content_equal content_include category price_upper price_lower ]
    end

    def check_condition(condition)
      condition.slice!(*permitted_parameters_for_index)
      dummy_params = {
        :account_type => 'income',
        :date => '1000-01-01',
        :content => 'dummy',
        :category => 'dummy',
        :price => 1,
      }
      account = Account.new(dummy_params)
      invalid_exception = ActiveRecord::RecordInvalid.new(account)

      if condition[:account_type] and not condition[:account_type] =~ /\A(income|expense)\z/
        invalid_exception.record.errors[:account_type] = 'is invalid'
      end
      
      [:date_before, :date_after].each do |date_query|
        if condition[date_query]
          if condition[date_query] =~ /\d{4}-\d{2}-\d{2}/
            begin
              Date.parse(condition[date_query])
            rescue ArgumentError
              invalid_exception.record.errors[date_query] = 'is invalid'
            end
          else
            invalid_exception.record.errors[date_query] = 'is invalid'
          end
        end
      end

      [:price_upper, :price_lower].each do |price_query|
        if condition[price_query] and not condition[price_query] =~ /\A\d+\z/
          invalid_exception.record.errors[price_query] = 'is invalid'
        end
      end

      raise invalid_exception unless invalid_exception.record.errors.empty?
    end
  end
end
