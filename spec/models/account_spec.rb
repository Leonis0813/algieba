# coding: utf-8
require 'rails_helper'

shared_context 'get accounts' do |query = {}|
  before(:all) do
    @result, accounts = Account.show(query)
    @accounts = accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
  end
end

shared_examples 'get expected accounts' do |size|
  it 'result is true' do
    expect(@result).to be true
  end

  it "size is #{size}" do
    expect(@accounts.size).to eq(size)
  end

  it 'should return accounts' do
    expect(@accounts).to match_array @expected_accounts
  end
end

describe Account, :type => :model do
  before(:all) do
    @income = {
      :account_type => 'income',
      :date => '1000-01-01',
      :content => 'テスト用データ',
      :category => 'テスト',
      :price => 100,
    }
    Account.create(@income)

    @expense = {
      :account_type => 'expense',
      :date => '1000-01-01',
      :content => 'テスト用データ',
      :category => 'テスト',
      :price => 100,
    }
    Account.create(@expense)
  end

  after(:all) { Account.delete_all }

  context 'find by account_type' do
    include_context 'get accounts', :account_type => 'income'
    before(:all) { @expected_accounts = [@income.values] }

    it_behaves_like 'get expected accounts', 1
  end

  context 'find by date' do
    include_context 'get accounts', :date => '1000-01-01'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like 'get expected accounts', 2
  end

  context 'find by content' do
    include_context 'get accounts', :content => 'テスト用データ'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like 'get expected accounts', 2
  end

  context 'find by category' do
    include_context 'get accounts', :category => 'テスト'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like 'get expected accounts', 2
  end

  context 'find by price' do
    include_context 'get accounts', :price => 100
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like 'get expected accounts', 2
  end

  context 'find by account_type and category' do
    include_context 'get accounts', :account_type => 'expense', :category => 'テスト'
    before(:all) { @expected_accounts = [@expense.values] }

    it_behaves_like 'get expected accounts', 1
  end

  context 'find by content and price' do
    include_context 'get accounts', :content => 'テスト用データ', :price => 100
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like 'get expected accounts', 2
  end

  context 'find by content and price' do
    include_context 'get accounts', :content => 'テスト用データ', :price => 1
    before(:all) { @expected_accounts = [] }

    it_behaves_like 'get expected accounts', 0
  end

  context 'find by no condition' do
    include_context 'get accounts'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like 'get expected accounts', 2
  end
end
