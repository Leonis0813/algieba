require 'date'

class Account < ActiveRecord::Base
  validates :account_type, :presence => true, :format => { :with => /income|expense/ }
  validates :date, :presence => true, :format => { :with => /\d{4}-\d{2}-\d{2}/ }
  validates :content, :presence => true
  validates :category, :presence => true
  validates :price, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  class << self
    def show(condition = {})
      check_condition(condition)
      Account.where(condition)
    end

    def update(params)
      condition, with = (params[:condition] || {}), params[:with]
      check_condition(condition)
      check_condition(with)

      account_attributes = %i[ account_type date content category price ]
      Account.where(condition.slice(*account_attributes)).map do |account|
        account.update_attributes(with)
        account.save!
      end
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
      dummy_params = {
        :account_type => 'income',
        :date => '1000-01-01',
        :content => 'dummy',
        :category => 'dummy',
        :price => 1,
      }
      account = Account.new(dummy_params)
      condition.each {|key, value| account.update_attribute(key, value) }
      raise ActiveRecord::RecordInvalid,new(account) if account.invalid?
    end
  end
end
