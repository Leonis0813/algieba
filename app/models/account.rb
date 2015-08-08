require 'date'

class Account < ActiveRecord::Base
  validates :account_type, :presence => true, :format => { :with => /income|expense/ }
  validates :date, :presence => true, :format => { :with => /\d{4}-\d{2}-\d{2}/ }
  validates :content, :presence => true
  validates :category, :presence => true
  validates :price, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  def create(params)
    account = Account.new(:account_type => params[:account_type],
                          :date => params[:date],
                          :content => params[:content],
                          :category => params[:category],
                          :price => params[:price].to_i)
    if account.save
      return [true, account]
    else
      return [false, account.errors.messages.keys]
    end
  end

  def show(params)
    account = Account.new(:account_type => params[:account_type] || 'income',
                          :date => params[:date] || Date.parse('1980-01-01'),
                          :content => params[:content] || 'content',
                          :category => params[:category] || 'category',
                          :price => params[:price] || 0)
    if account.valid?
      conditions = params.slice :account_type, :date, :content, :category, :price
      [true, Account.where(conditions)]
    else
      [false, account.errors.messages.keys]
    end
  end

  def update(params)
    condition = params[:condition] || {}
    with = params[:with]
    account = Account.new(:account_type => condition[:account_type] || 'income',
                          :date => condition[:date] || Date.parse('1980-01-01'),
                          :content => condition[:content] || 'content',
                          :category => condition[:category] || 'category',
                          :price => condition[:price] || 0)
    if account.valid?
      conditions = condition.slice :account_type, :date, :content, :category, :price
      accounts = Account.where(conditions)
      accounts.each do |account|
        return [false, account.errors.messages.keys] unless account.update with
      end
      [true, accounts]
    else
      [false, account.errors.messages.keys]
    end
  end

  def destroy(params)
    account = Account.new(:account_type => params[:account_type] || 'income',
                          :date => params[:date] || Date.parse('1980-01-01'),
                          :content => params[:content] || 'content',
                          :category => params[:category] || 'category',
                          :price => params[:price] || 0)
    if account.valid?
      conditions = params.slice :account_type, :date, :content, :category, :price
      Account.where(conditions).each do |account|
        account.destroy
      end
      [true, nil]
    else
      [false, account.errors.messages.keys]
    end
  end

  def settle(period)
    return [false, :period] unless period =~ /yearly|monthly|daily/

    income_records = Account.where(:account_type => 'income').pluck(:date, :price).map do |record|
      {:date => record.date, :price => record.price}
    end
    expense_records = Account.where(:account_type => 'expense').pluck(:date, :price).map do |record|
      {:date => record.date, :price => record.price}
    end

    format = case period
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
    grouped_income_records.each do |period, prices|
      incomes.merge!({period => prices.inject(0){|sum, price| sum + price }})
    end
    grouped_expense_records.each do |period, prices|
      expenses.merge!({period => prices.inject(0){|sum, price| sum + price }})
    end

    periods = incomes.keys | expenses.keys
    settlements = {}
    periods.each do |period|
      settlements.merge!({period => (incomes[period] || 0) - (expenses[period] || 0)})
    end
    [true, settlements]
  end
end
