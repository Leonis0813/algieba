require 'date'

class Account < ActiveRecord::Base
  validates :account_type, :presence => true, :format => { :with => /income|expense/ }
  validates :date, :presence => true, :format => { :with => /\d{4}-\d{2}-\d{2}/ }
  validates :content, :presence => true
  validates :category, :presence => true
  validates :price, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  class << self
    def show(params = {})
      invalid_conditions = check_condition(params)
      if invalid_conditions.empty?
        conditions = params.slice :account_type, :date, :content, :category, :price
        [true, Account.where(conditions)]
      else
        [false, invalid_conditions]
      end
    end

    def update(params)
      condition = params[:condition] || {}
      invalid_conditions = check_condition(condition)
      return [false, invalid_conditions] unless invalid_conditions.empty?

      return [false, [:with]] if params[:with].empty?
      with = params[:with]
      invalid_values = check_condition(with)
      return [false, invalid_values] unless invalid_values.empty?

      conditions = condition.slice :account_type, :date, :content, :category, :price
      accounts = Account.where(conditions)
      accounts.each do |account|
        account.update_attributes with
      end
      [true, accounts]
    end

    def destroy(params = {})
      invalid_conditions = check_condition(params)
      if invalid_conditions.empty?
        conditions = params.slice :account_type, :date, :content, :category, :price
        Account.where(conditions).each do |account|
          account.delete
        end
        [true, []]
      else
        [false, invalid_conditions]
      end
    end

    def settle(interval)
      return nil unless interval =~ /yearly|monthly|daily/

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
      [true, settlements]
    end

    private
    def check_condition(condition)
      [].tap do |invalid_params|
        if condition[:account_type] and
           not (condition[:account_type] == 'income' or condition[:account_type] == 'expense')
          invalid_params << :account_type
        end
        if condition[:date]
          if condition[:date] =~ /\A\d{4}\-\d{2}\-\d{2}\z/
            year, month, day = condition[:date].split('-')
            unless 1 <= month.to_i and month.to_i <= 12 or 1 <= day.to_i and day.to_i <= 31
              invalid_params << :date
            end
          else
            invalid_params << :date
          end
        end
        if condition[:price]
          unless condition[:price] =~ /\A[1-9]\d*\z/
            invalid_params << :price
          end
        end
      end
    end
  end
end
