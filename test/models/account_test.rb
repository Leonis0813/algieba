# -*- coding: utf-8 -*-
require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test 'should return accounts(account_type)' do
    result = Account.show(:account_type => 'income')
    assert_equal [true, [accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return accounts(date)' do
    result = Account.show(:date => '1000-01-01')
    assert_equal [true, [accounts(:expense), accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return accounts(content)' do
    result = Account.show(:content => 'テスト用データ')
    assert_equal [true, [accounts(:expense), accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return accounts(category)' do
    result = Account.show(:category => 'テスト')
    assert_equal [true, [accounts(:expense), accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return accounts(price)' do
    result = Account.show(:price => 100)
    assert_equal [true, [accounts(:expense), accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return accounts(account_type, category)' do
    result = Account.show(:account_type => 'expense', :category => 'テスト')
    assert_equal [true, [accounts(:expense)]], [result.first, result.last.to_a]
  end

  test 'should return accounts(content, price)' do
    result = Account.show(:content => 'テスト用データ', :price => 100)
    assert_equal [true, [accounts(:expense), accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return nothing' do
    result = Account.show(:content => 'テスト用データ', :price => 1)
    assert_equal [true, []], [result.first, result.last.to_a]
  end

  test 'should return all accounts' do
    result = Account.show
    assert_equal [true, [accounts(:expense), accounts(:income)]], [result.first, result.last.to_a]
  end

  test 'should return updated accounts(account_type)' do
    result = Account.new.update({
      :condition => {:account_type => 'expense'},
      :with => {:account_type => 'income'},
    })
    assert_equal [true, [accounts(:expense)]], [result.first, result.last.to_a]
  end

  test 'should return updated accounts(date)' do
    now = Time.now
    attributes = {
      :account_type => 'income',
      :date => now.strftime('%Y-%m-%d'),
      :content => 'テスト用データ',
      :category => 'テスト',
      :price => 100,
    }
    expected_account = Account.create!(attributes)
    expected_account.date = now - 24 * 60 * 60
    result = Account.new.update({
      :condition => {:date => now.strftime('%Y-%m-%d')},
      :with => {:date => now - 24 * 60 * 60},
    })
    assert_equal [true, [expected_account]], [result.first, result.last.to_a]
    Account.delete_all
  end

  test 'should return updated accounts(content)' do
    income = accounts(:income)
    income.content = '更新後データ'
    expense = accounts(:expense)
    expense.content = '更新後データ'
    expected_accounts = [expense, income]
    result = Account.new.update({
      :condition => {:content => 'テスト用データ'},
      :with => {:content => '更新後データ'},
    })
    assert_equal [true, expected_accounts], [result.first, result.last.to_a]
  end

  test 'should return updated accounts(category)' do
    income = accounts(:income)
    income.category = '更新'
    expense = accounts(:expense)
    expense.category = '更新'
    expected_accounts = [expense, income]
    result = Account.new.update({
      :condition => {:category => 'テスト'},
      :with => {:category => '更新'},
    })
    assert_equal [true, expected_accounts], [result.first, result.last.to_a]
  end

  test 'should return updated accounts(price)' do
    income = accounts(:income)
    income.price = 1000
    expense = accounts(:expense)
    expense.price = 1000
    expected_accounts = [expense, income]
    result = Account.new.update({
      :condition => {:price => 100},
      :with => {:price => 1000},
    })
    assert_equal [true, expected_accounts], [result.first, result.last.to_a]
  end

  test 'should return updated accounts(account_type, category, price)' do
    expense = accounts(:expense)
    expense.account_type = 'income'
    expense.category = 'テスト'
    expense.price = 10000
    result = Account.new.update({
      :condition => {
        :account_type => 'expense',
        :price => 100,
      },
      :with => {
        :account_type => 'income',
        :category => 'テスト',
        :price => 10000,
      },
    })
    assert_equal [true, [expense]], [result.first, result.last.to_a]
  end

  test 'should return no updated accounts' do
    result = Account.new.update({
      :condition => {
        :account_type => 'expense',
        :price => 1,
      },
      :with => {
        :account_type => 'income',
        :category => 'テスト',
        :price => 10000,
      },
    })
    assert_equal [true, []], [result.first, result.last.to_a]
  end

  test 'should return all updated accounts' do
    income = accounts(:income)
    income.price = 100000
    expense = accounts(:expense)
    expense.account_type = 'income'
    expense.price = 100000
    result = Account.new.update({
      :with => {
        :account_type => 'income',
        :price => 100000,
      },
    })
    assert_equal [true, [expense, income]], [result.first, result.last.to_a]
  end

  test 'should return empty array due to success(account_type)' do
    result = Account.new.destroy({:account_type => 'income'})
    assert_equal [true, []], result
  end

  test 'should return empty array due to success(date)' do
    result = Account.new.destroy({:date => '1000-01-01'})
    assert_equal [true, []], result
  end

  test 'should return empty array due to success(content)' do
    result = Account.new.destroy({:content => 'テスト用データ'})
    assert_equal [true, []], result
  end

  test 'should return empty array due to success(category)' do
    result = Account.new.destroy({:category => 'テスト'})
    assert_equal [true, []], result
  end

  test 'should return empty array due to success(price)' do
    result = Account.new.destroy({:price => 100})
    assert_equal [true, []], result
  end

  test 'should return empty array due to success(date, price)' do
    result = Account.new.destroy({
      :date => '1000-01-01',
      :price => 100,
    })
    assert_equal [true, []], result
  end

  test 'should return empty array due to success but no deleted accounts(date, price)' do
    result = Account.new.destroy({
      :date => '1000-01-01',
      :price => 1,
    })
    assert_equal [true, []], result
  end

  test 'should return empty array due to success' do
    result = Account.new.destroy
    assert_equal [true, []], result
  end

  test 'should return settlements(yearly)' do
    result = Account.new.settle('yearly')
    assert_equal [true, {'1000' => 0}], result
  end

  test 'should return settlements(monthly)' do
    result = Account.new.settle('monthly')
    assert_equal [true, {'1000-01' => 0}], result
  end

  test 'should return settlements(daily)' do
    result = Account.new.settle('daily')
    assert_equal [true, {'1000-01-01' => 0}], result
  end
end
