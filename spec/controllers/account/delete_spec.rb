# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  income = {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  expense = {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  account_keys = %w[account_type date content category price]

  include_context 'Controller: 共通設定'

  context '正常系' do
    [
      ['種類を指定する場合', {'account_type' => 'expense'}],
      ['日付を指定する場合', {'date' => '1000-01-01'}],
      ['内容を指定する場合', {'content' => '機能テスト用データ'}],
      ['カテゴリを指定する場合', {'category' => '機能テスト'}],
      ['金額を指定する場合', {'price' => 100}],
      ['種類と金額を指定してカテゴリを更新する場合', {'account_type' => 'expense', 'price' => 100}],
      ['条件を指定せずに金額を更新する場合', {}],
    ].each do |description, condition|
      context description do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.delete('/accounts', condition)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like 'Controller: 家計簿が正しく削除されていることを確認する'
      end
    end
  end

  context '異常系' do
    [
      ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}, {}],
      ['不正な日付を指定する場合', {'date' => 'invalid_date'}, {'price' => 100}],
      ['不正な金額を指定する場合', {'price' => 'invalid_price'}, {'category' => '機能テスト'}],
    ].each do |description, invalid_condition, condition|
      context description do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.delete('/accounts', condition.merge(invalid_condition))
          @pbody = JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like '400エラーをチェックする', invalid_condition.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
