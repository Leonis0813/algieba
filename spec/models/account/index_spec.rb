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
        [{:account_type => 'income'}, [income]],
        [{:date_before => '1000-01-01'}, [income]],
        [{:date_after => '1000-01-02'}, [expense]],
        [{:content_equal => 'モジュールテスト用データ1'}, [income]],
        [{:content_include => 'モジュールテスト'}, [income, expense]],
        [{:category => 'algieba'}, [income, expense]],
        [{:price_upper => 100}, [income, expense]],
        [{:price_lower => 100}, [expense]],
        [{:account_type => 'expense', :category => 'algieba'}, [expense]],
        [{:date_before => '1000-01-01', :content_include => 'テスト'}, [income]],
        [{:content_equal => 'モジュールテスト用データ2', :price_upper => 1000}, []],
        [{:date_after => '1000-01-01', :price_lower => 1000}, [income, expense]],
        [
          {
            :account_type => 'income',
            :date_before => '1000-01-10',
            :date_after => '1000-01-01',
            :content_include => 'モジュールテスト',
            :price_upper => 100,
            :price_lower => 1000,
          },
          [income],
        ],
        [{}, [income, expense]],
      ].each do |query, expected_accounts|
        description = query.empty? ? '条件を指定しない場合' : "#{query.keys.join(',')}を指定する場合"
        context description do
          include_context 'Model: 家計簿を検索する', query
          it_behaves_like 'Model: 家計簿が正しく検索されていることを確認する', expected_accounts
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
