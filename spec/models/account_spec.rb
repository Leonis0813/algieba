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

  context '家計簿の種類で検索する' do
    include_context '家計簿を取得する', :account_type => 'income'
    before(:all) { @expected_accounts = [@income.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 1
  end

  context '日付で検索する' do
    include_context '家計簿を取得する', :date => '1000-01-01'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 2
  end

  context '内容で検索する' do
    include_context '家計簿を取得する', :content => 'テスト用データ'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 2
  end

  context 'カテゴリで検索する' do
    include_context '家計簿を取得する', :category => 'テスト'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 2
  end

  context '金額で検索する' do
    include_context '家計簿を取得する', :price => 100
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 2
  end

  context '家計簿の種類とカテゴリで検索する' do
    include_context '家計簿を取得する', :account_type => 'expense', :category => 'テスト'
    before(:all) { @expected_accounts = [@expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 1
  end

  context '内容と金額で検索する' do
    include_context '家計簿を取得する', :content => 'テスト用データ', :price => 100
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 2
  end

  context '内容と金額で検索する' do
    include_context '家計簿を取得する', :content => 'テスト用データ', :price => 1
    before(:all) { @expected_accounts = [] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 0
  end

  context '条件なしで検索する' do
    include_context '家計簿を取得する'
    before(:all) { @expected_accounts = [@income.values, @expense.values] }

    it_behaves_like '家計簿が正しく取得されていることを確認する', :size => 2
  end
end
