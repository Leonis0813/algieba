class Account < ActiveRecord::Base
  validates :type, :presence => true, :format => { :with => /income|expense/ }
  validates :date, :presence => true, :format => { :with => /\d{4}-\d{2}-\d{2}/ }
  validates :content, :presence => true
  validates :category, :presence => true
  validates :price, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  def create
    account = Account.new(:type => params[:type],
                          :date => params[:date],
                          :content => params[:content],
                          :category => params[:category],
                          :price => params[:price])
    if account.save
      return [true, account]
    else
      return [false, account.errors.messages.keys]
    end
  end

  def show(params)
    account = Account.new(:type => params[:type] || 'income',
                          :date => params[:date] || '0000-00-00',
                          :content => params[:content] || 'content',
                          :category => params[:category] || 'category',
                          :price => params[:price] || 0)
    if account.valid?
      conditions = params.slice :type, :date, :content, :category, :price
      [true, Account.where(conditions)]
    else
      [false, account.errors.messages.keys]
    end
  end
end
