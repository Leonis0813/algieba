# coding: utf-8
require 'rails_helper'

describe AccountsController, :type => :controller do
  income = {'account_type' => 'income', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  expense = {'account_type' => 'expense', 'date' => '1000-01-01', 'content' => '機能テスト用データ', 'category' => '機能テスト', 'price' => 100}
  account_keys = %w[account_type date content category price]

  include_context 'Controller: 共通設定'

  context '正常系' do
    [
      ['種類を指定して種類を更新する場合', {'account_type' => 'expense'}, {'account_type' => 'income'}, [expense]],
      ['日付を指定して内容を更新する場合', {'date' => '1000-01-01'}, {'content' => '更新後データ'}, [income, expense]],
      ['内容を指定して金額を更新する場合', {'content' => '機能テスト用データ'}, {'price' => 10000}, [income, expense]],
      ['カテゴリを指定して種類を更新する場合', {'category' => '機能テスト'}, {'account_type' => 'expense'}, [income, expense]],
      ['金額を指定してカテゴリを更新する場合', {'price' => 100}, {'category' => '更新'}, [income, expense]],
      ['種類と金額を指定してカテゴリを更新する場合', {'account_type' => 'expense', 'price' => 100}, {'category' => '更新'}, [expense]],
      ['条件を指定せずに金額を更新する場合', nil, {'price' => 10}, [income, expense]],
      ['条件を指定せずに内容とカテゴリを更新する場合', nil, {'content' => '更新後データ', 'category' => '更新'}, [income, expense]],
    ].each do |description, condition, with, updated_accounts|
      context description do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.put('/accounts', {:condition => condition, :with => with}.select {|key, value| value })
          @pbody = JSON.parse(@res.body)
          @actual_accounts = @pbody.map {|account| account.slice(*account_keys) }
          @expected_accounts = updated_accounts.map {|account| account.merge(with) }
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like 'Controller: 家計簿が正しく更新されていることを確認する'
      end
    end
  end

  context '異常系' do
    [
      ['不正な種類を指定する場合', {'account_type' => 'invalid_type'}, {'account_type' => 'expense'}],
      ['不正な日付を指定する場合', {'date' => '01-01-1000'}, {'price' => 1000}],
      ['不正な金額を指定する場合', {'price' => -1}, {'account_type' => 'expense'}],
      ['不正な種類で更新する場合', nil, {'account_type' => 'invalid_type'}],
      ['不正な日付で更新する場合', nil, {'date' => 'invalid_date'}],
      ['不正な金額で更新する場合', nil, {'price' => 100.5}],
    ].each do |description, condition, with|
      context description do
        before(:all) do
          [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
          @res = @client.put('/accounts', {:condition => condition, :with => with}.select {|key, value| value })
          @pbody = JSON.parse(@res.body)
        end
        after(:all) { @client.delete('/accounts') }

        it_behaves_like '400エラーをチェックする', (condition || with).keys.map {|key| "invalid_param_#{key}" }
      end
    end

    context '更新後の値がない場合' do
      before(:all) do
        [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
        @res = @client.put('/accounts', {:with => {}})
        @pbody = JSON.parse(@res.body)
      end
      after(:all) { @client.delete('/accounts') }

      it_behaves_like '400エラーをチェックする', ['absent_param_with']
    end

    context 'with パラメーターがない場合' do
      before(:all) do
        [income, expense].each {|account| @client.post('/accounts', {:accounts => account}) }
        @res = @client.put('/accounts')
        @pbody = JSON.parse(@res.body)
      end
      after(:all) { @client.delete('/accounts') }

      it_behaves_like '400エラーをチェックする', ['absent_param_with']
    end
  end
end
