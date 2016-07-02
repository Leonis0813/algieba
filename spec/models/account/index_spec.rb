# coding: utf-8
require 'rails_helper'

describe Account, :type => :model do
  income = {
    :id => 1,
    :account_type => 'income',
    :date => '1000-01-01',
    :content => 'モジュールテスト用データ1',
    :category => 'algieba',
    :price => 1000,
  }
  expense = {
    :id => 2,
    :account_type => 'expense',
    :date => '1000-01-05',
    :content => 'モジュールテスト用データ2',
    :category => 'algieba',
    :price => 100,
  }

  before(:all) { [income, expense].each {|account| Account.create!(account) } }
  after(:all) { Account.delete_all }

  context 'index' do
    context '正常系' do
      [
        ['種類を指定する', {:account_type => 'income'}, [income.values]],
        ['日付を指定する', {:date => '1000-01-01'}, [income.values, expense.values]],
        ['内容を指定する', {:content => 'テスト用データ'}, [income.values, expense.values]],
        ['カテゴリを指定する', {:category => 'テスト'}, [income.values, expense.values]],
        ['金額を指定する', {:price => 100}, [income.values, expense.values]],
        ['種類とカテゴリを指定する', {:account_type => 'expense', :category => 'テスト'}, [expense.values]],
        ['内容と金額を指定する', {:content => 'テスト用データ', :price => 100}, [income.values, expense.values]],
        ['内容と金額を指定する', {:content => 'テスト用データ', :price => 1}, []],
        ['条件を指定しない', {}, [income.values, expense.values]],
      ].each do |description, query, expected_accounts|
        context description do
          include_context 'Model: 家計簿を取得する', query

          it_behaves_like 'Model: 家計簿が正しく取得されていることを確認する', :size => expected_accounts.size, :accounts => expected_accounts
        end
      end
    end

    context '異常系' do
      [
        ['不正な種類を指定する', {:account_type => 'invalid_type'}, [:account_type]],
        ['不正な日付を指定する', {:date => '1000-00-00'}, [:date]],
        ['不正な金額を指定する', {:price => -100}, [:price]],
        ['不正な種類と金額を指定する', {:account_type => 'invalid_type', :date => '1000-01-01', :price => 'invalid_price'}, [:account_type, :price]],
      ].each do |description, query, invalid_columns|
        context description do
          it 'ActiveRecord::RecordInvalidが発生すること' do
            expect{ Account.show(query) }.to raise_error(ActiveRecord::RecordInvalid) do |e|
              expect(e.record.errors.messages.keys).to eq invalid_columns
            end
          end
        end
      end
    end
  end
end
