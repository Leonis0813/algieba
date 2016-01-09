# coding: utf-8
require 'rails_helper'

shared_context '家計簿を取得する' do |query = {}|
  before(:all) do
    @result, accounts = Account.show(query)
    @accounts = accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
  end
end

shared_context '家計簿を更新する' do |condition, with|
  before(:all) do
    @result, accounts = Account.update({:condition => condition, :with => with})
    @accounts = accounts.to_a.map do |account|
      [account.account_type, account.date.strftime('%Y-%m-%d'), account.content, account.category, account.price]
    end
  end
end

shared_context '家計簿を削除する' do |condition|
  before(:all) { @result, @accounts = Account.destroy(condition) }
end

shared_context '収支を計算する' do |interval|
  before(:all) { @result, @settlement = Account.settle(interval) }
end

shared_examples '家計簿が正しく取得されていることを確認する' do |expected|
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it "取得した家計簿の数が#{expected[:size]}であること" do
    expect(@accounts.size).to eq expected[:size]
  end

  it '取得した家計簿が正しいこと' do
    expect(@accounts).to match_array expected[:accounts]
  end
end

shared_examples '家計簿が正しく更新されていることを確認する' do |expected|
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it "取得した家計簿の数が#{expected[:size]}であること" do
    expect(@accounts.size).to eq(expected[:size])
  end

  it '取得した家計簿が正しいこと' do
    expect(@accounts).to match_array @expected_accounts
  end
end

shared_examples '家計簿が正しく削除されていることを確認する' do
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it '取得した家計簿が正しいこと' do
    expect(@accounts).to match_array []
  end
end

shared_examples '収支が正しく計算されていることを確認する' do |settlement|
  it '結果がtrueであること' do
    expect(@result).to be true
  end

  it '計算結果が正しいこと' do
    expect(@settlement).to eq settlement
  end
end

describe Account, :type => :model do
  income = {
    :account_type => 'income', :date => '1000-01-01', :content => 'テスト用データ', :category => 'テスト', :price => 100
  }
  expense = {
    :account_type => 'expense', :date => '1000-01-01', :content => 'テスト用データ', :category => 'テスト', :price => 100
  }

  context 'show' do
    before(:all) { [income, expense].each {|account| Account.create(account) } }
    after(:all) { Account.delete_all }

    [
      ['家計簿の種類を指定する', {:account_type => 'income'}, [income.values]],
      ['日付を指定する', {:date => '1000-01-01'}, [income.values, expense.values]],
      ['内容を指定する', {:content => 'テスト用データ'}, [income.values, expense.values]],
      ['カテゴリを指定する', {:category => 'テスト'}, [income.values, expense.values]],
      ['金額を指定する', {:price => 100}, [income.values, expense.values]],
      ['家計簿の種類とカテゴリを指定する', {:account_type => 'expense', :category => 'テスト'}, [expense.values]],
      ['内容と金額を指定する', {:content => 'テスト用データ', :price => 100}, [income.values, expense.values]],
      ['内容と金額を指定する', {:content => 'テスト用データ', :price => 1}, []],
      ['条件を指定しない', {}, [income.values, expense.values]],
    ].each do |description, query, expected_accounts|
      context description do
        include_context '家計簿を取得する', query

        it_behaves_like '家計簿が正しく取得されていることを確認する', :size => expected_accounts.size, :accounts => expected_accounts
      end
    end
  end

  context 'update' do
    [
      ['家計簿の種類を条件にして家計簿の種類を変更する', {:account_type => 'expense'}, {:account_type => 'income'}, [expense]],
      ['日付を条件にして日付を変更する', {:date => '1000-01-01'}, {:date => '1000-02-01'}, [income, expense]],
      ['内容を条件にして内容を変更する', {:content => 'テスト用データ'}, {:content => '更新後データ'}, [income, expense]],
      ['カテゴリを条件にしてカテゴリを変更する', {:category => 'テスト'}, {:category => '更新'}, [income, expense]],
      ['金額を条件にして金額を変更する', {:price => 100}, {:price => 1000}, [income, expense]],
      [
        '家計簿の種類と金額を条件にして家計簿の種類とカテゴリと金額を変更する',
        {:account_type => 'expense', :price => 100},
        {:account_type => 'income', :category => 'テスト', :price => 10000},
        [expense]
      ],
      [
        '家計簿の種類と金額を条件にして家計簿の種類とカテゴリと金額を変更する',
        {:account_type => 'expense', :price => 1},
        {:account_type => 'income', :category => 'テスト', :price => 10000},
        []
      ],
      ['条件を指定せずに家計簿の種類と金額を変更する', {}, {:account_type => 'income', :price => 100000}, [income, expense]],
    ].each do |description, condition, with, updated_accounts|
      context description do
        before(:all) do
          [income, expense].each {|account| Account.create(account) }
          @expected_accounts = updated_accounts.map {|account| account.merge(with).values }
        end
        after(:all) { Account.delete_all }
        include_context '家計簿を更新する', condition, with

        it_behaves_like '家計簿が正しく更新されていることを確認する', :size => updated_accounts.size
      end
    end
  end

  context 'destroy' do
    [
      ['家計簿の種類を指定する', {:account_type => 'income'}],
      ['日付を指定する', {:date => '1000-01-01'}],
      ['内容を指定する', {:content => 'テスト用データ'}],
      ['カテゴリを指定する', {:category => 'テスト'}],
      ['金額を指定する', {:price => 100}],
      ['日付と金額を指定する', {:date => '1000-01-01', :price => 100}],
      ['日付と金額を指定する', {:date => '1000-01-01', :price => 1}],
      ['条件を指定しない', {}],
    ].each do |description, condition|
      before(:all) { [income, expense].each {|account| Account.create(account) } }
      after(:all) { Account.delete_all }
      include_context '家計簿を削除する', condition

      it_behaves_like '家計簿が正しく削除されていることを確認する'
    end
  end

  context 'settle' do
    before(:all) { [income, expense].each {|account| Account.create(account) } }
    after(:all) { Account.delete_all }

    [
      ['年次を指定する', 'yearly', {'1000' => 0}],
      ['月次を指定する', 'monthly', {'1000-01' => 0}],
      ['日次を指定する', 'daily', {'1000-01-01' => 0}],
    ].each do |description, interval, settlement|
      context description do
        include_context '収支を計算する', interval

        it_behaves_like '収支が正しく計算されていることを確認する', settlement
      end
    end
  end
end
