# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  income = {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  expense = {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  account_keys = %w[account_type date content category price]

  include_context 'Controller: 共通設定'

  context '正常系' do
    before(:all) do
      @res = @client.post('/accounts', {:accounts => income})
      @pbody = JSON.parse(@res.body)
      @actual_account = @pbody.slice(*account_keys)
    end
    after(:all) { @client.delete('/accounts') }

    it_behaves_like 'Controller: 家計簿が正しく登録されていることを確認する', income
  end

  context '異常系' do
    [
      ['種類がない場合', ['account_type']],
      ['日付がない場合', ['date']],
      ['内容がない場合', ['content']],
      ['カテゴリがない場合', ['category']],
      ['金額がない場合', ['price']],
      ['日付と金額がない場合', ['date', 'price']],
    ].each do |description, deleted_keys|
      context description do
        before(:all) do
          selected_keys = account_keys - deleted_keys
          @res = @client.post('/accounts', {:accounts => income.slice(*selected_keys)})
          @pbody = JSON.parse(@res.body)
        end

        it_behaves_like '400エラーをチェックする', deleted_keys.map {|key| "absent_param_#{key}" }
      end
    end

    [{}, {:accounts => {}}].each do |params|
      context 'accounts パラメーターがない場合' do
        before(:all) do
          @res = @client.post('/accounts', params)
          @pbody = JSON.parse(@res.body)
        end

        it_behaves_like '400エラーをチェックする', ['absent_param_accounts']
      end
    end

    [
      ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}],
      ['不正な日付を指定する場合', {'date' => 'invalid_date'}],
      ['不正な金額を指定する場合', {'price' => 'invalid_price'}],
      ['不正な種類と金額を指定する場合', {'account_type' => 'invalid_type', 'price' => 'invalid_price'}],
    ].each do |description, invalid_param|
      context description do
        before(:all) do
          @res = @client.post('/accounts', {:accounts => expense.merge(invalid_param)})
          @pbody = JSON.parse(@res.body)
        end

        it_behaves_like '400エラーをチェックする', invalid_param.keys.map {|key| "invalid_param_#{key}" }
      end
    end
  end
end
